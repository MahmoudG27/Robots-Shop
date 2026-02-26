package main

import (
	"encoding/json"
	"fmt"
	"log"
	"math/rand"
	"net/http"
	"os"
	"strconv"
	"time"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	amqp "github.com/rabbitmq/amqp091-go"
)

const (
	Service = "dispatch"
)

var (
	amqpUri          string
	rabbitChan       *amqp.Channel
	rabbitCloseError chan *amqp.Error
	rabbitReady      chan bool
	errorPercent     int

	dataCenters = []string{
		"asia-northeast2",
		"asia-south1",
		"europe-west3",
		"us-east1",
		"us-west1",
	}

	// Prometheus metrics
	ordersProcessed = prometheus.NewCounter(
		prometheus.CounterOpts{
			Name: "dispatch_orders_total",
			Help: "Total number of orders processed",
		},
	)
	orderProcessingErrors = prometheus.NewCounter(
		prometheus.CounterOpts{
			Name: "dispatch_orders_errors_total",
			Help: "Total number of orders failed to process",
		},
	)
)

func init() {
	// register Prometheus metrics
	prometheus.MustRegister(ordersProcessed)
	prometheus.MustRegister(orderProcessingErrors)
}

func connectToRabbitMQ(uri string) *amqp.Connection {
	for {
		conn, err := amqp.Dial(uri)
		if err == nil {
			return conn
		}
		log.Println(err)
		log.Printf("Reconnecting to %s\n", uri)
		time.Sleep(1 * time.Second)
	}
}

func rabbitConnector(uri string) {
	var rabbitErr *amqp.Error

	for {
		rabbitErr = <-rabbitCloseError
		if rabbitErr == nil {
			return
		}

		log.Printf("Connecting to %s\n", amqpUri)
		rabbitConn := connectToRabbitMQ(uri)
		rabbitConn.NotifyClose(rabbitCloseError)

		var err error
		rabbitChan, err = rabbitConn.Channel()
		failOnError(err, "Failed to create channel")

		err = rabbitChan.ExchangeDeclare("robot-shop", "direct", true, false, false, false, nil)
		failOnError(err, "Failed to create exchange")

		queue, err := rabbitChan.QueueDeclare("orders", true, false, false, false, nil)
		failOnError(err, "Failed to create queue")

		err = rabbitChan.QueueBind(queue.Name, "orders", "robot-shop", false, nil)
		failOnError(err, "Failed to bind queue")

		rabbitReady <- true
	}
}

func failOnError(err error, msg string) {
	if err != nil {
		log.Fatalf("%s : %s", msg, err)
	}
}

func getOrderId(order []byte) string {
	id := "unknown"
	var f interface{}
	err := json.Unmarshal(order, &f)
	if err == nil {
		m := f.(map[string]interface{})
		id = m["orderid"].(string)
	}
	return id
}

func processOrder(orderId string) {
	time.Sleep(time.Duration(42+rand.Int63n(42)) * time.Millisecond)
	if rand.Intn(100) < errorPercent {
		orderProcessingErrors.Inc()
		log.Printf("Order %s failed", orderId)
	} else {
		ordersProcessed.Inc()
		log.Printf("Order %s processed", orderId)
	}
}

func main() {
	rand.Seed(time.Now().Unix())

	// Init amqpUri
	amqpHost, ok := os.LookupEnv("AMQP_HOST")
	if !ok {
		amqpHost = "rabbitmq"
	}
	amqpUri = fmt.Sprintf("amqp://guest:guest@%s:5672/", amqpHost)

	errorPercent = 0
	if epct, ok := os.LookupEnv("DISPATCH_ERROR_PERCENT"); ok {
		if epcti, err := strconv.Atoi(epct); err == nil {
			if epcti > 100 {
				epcti = 100
			}
			if epcti < 0 {
				epcti = 0
			}
			errorPercent = epcti
		}
	}
	log.Printf("Error Percent is %d\n", errorPercent)

	rabbitCloseError = make(chan *amqp.Error)
	rabbitReady = make(chan bool)
	go rabbitConnector(amqpUri)
	rabbitCloseError <- amqp.ErrClosed

	// Start Prometheus metrics server
	go func() {
		http.Handle("/metrics", promhttp.Handler())
		log.Println("Prometheus metrics available at :9090/metrics")
		log.Fatal(http.ListenAndServe(":9090", nil))
	}()

	// Consume RabbitMQ messages
	go func() {
		for {
			ready := <-rabbitReady
			log.Printf("Rabbit MQ ready %v\n", ready)

			msgs, err := rabbitChan.Consume("orders", "", true, false, false, false, nil)
			failOnError(err, "Failed to consume")

			for d := range msgs {
				id := getOrderId(d.Body)
				go processOrder(id)
			}
		}
	}()

	log.Println("Waiting for messages")
	select {}
}