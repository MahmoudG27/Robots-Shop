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

type HealthResponse struct {
	Status string `json:"status"`
}

const Service = "dispatch"

var (
	amqpUri          string
	rabbitChan       *amqp.Channel
	rabbitCloseError chan *amqp.Error
	rabbitReady      chan bool
	errorPercent     int

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
	prometheus.MustRegister(ordersProcessed)
	prometheus.MustRegister(orderProcessingErrors)
}

func connectToRabbitMQ(uri string) *amqp.Connection {
	for {
		conn, err := amqp.Dial(uri)
		if err == nil {
			return conn
		}
		log.Println("RabbitMQ connection failed, retrying...")
		time.Sleep(2 * time.Second)
	}
}

func rabbitConnector(uri string) {
	for range rabbitCloseError {

		log.Printf("Connecting to RabbitMQ: %s\n", uri)

		conn := connectToRabbitMQ(uri)
		rabbitCloseError = make(chan *amqp.Error)
		conn.NotifyClose(rabbitCloseError)

		var err error
		rabbitChan, err = conn.Channel()
		if err != nil {
			log.Fatalf("Failed to create channel: %v", err)
		}

		err = rabbitChan.ExchangeDeclare(
			"robot-shop",
			"direct",
			true,
			false,
			false,
			false,
			nil,
		)
		if err != nil {
			log.Fatalf("Exchange error: %v", err)
		}

		queue, err := rabbitChan.QueueDeclare(
			"orders",
			true,
			false,
			false,
			false,
			nil,
		)
		if err != nil {
			log.Fatalf("Queue error: %v", err)
		}

		err = rabbitChan.QueueBind(
			queue.Name,
			"orders",
			"robot-shop",
			false,
			nil,
		)
		if err != nil {
			log.Fatalf("Bind error: %v", err)
		}

		rabbitReady <- true
	}
}

func getOrderId(order []byte) string {
	id := "unknown"

	var data map[string]interface{}
	err := json.Unmarshal(order, &data)
	if err != nil {
		return id
	}

	if val, ok := data["orderid"].(string); ok {
		id = val
	}

	return id
}

func processOrder(orderId string) {
	time.Sleep(time.Duration(40+rand.Int63n(60)) * time.Millisecond)

	if rand.Intn(100) < errorPercent {
		orderProcessingErrors.Inc()
		log.Printf("Order FAILED: %s", orderId)
	} else {
		ordersProcessed.Inc()
		log.Printf("Order OK: %s", orderId)
	}
}

func liveHandler(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(HealthResponse{Status: "alive"})
}

func readyHandler(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(HealthResponse{Status: "ready"})
}

func main() {

	rand.Seed(time.Now().UnixNano())

	amqpHost := os.Getenv("AMQP_HOST")
	if amqpHost == "" {
		amqpHost = "rabbitmq"
	}

	amqpUri = fmt.Sprintf("amqp://guest:guest@%s:5672/", amqpHost)

	if ep := os.Getenv("DISPATCH_ERROR_PERCENT"); ep != "" {
		if v, err := strconv.Atoi(ep); err == nil {
			if v < 0 {
				v = 0
			}
			if v > 100 {
				v = 100
			}
			errorPercent = v
		}
	}

	log.Printf("Dispatch error percent: %d", errorPercent)

	rabbitCloseError = make(chan *amqp.Error)
	rabbitReady = make(chan bool)

	go rabbitConnector(amqpUri)

	// force first connection
	rabbitCloseError <- amqp.ErrClosed

	go func() {
		mux := http.NewServeMux()

		// metrics
		mux.Handle("/metrics", promhttp.Handler())

		// health
		mux.HandleFunc("/health/live", liveHandler)
		mux.HandleFunc("/health/ready", readyHandler)

		log.Println("HTTP server on :8080")
		log.Fatal(http.ListenAndServe(":8080", mux))
	}()

	// consumer
	go func() {
		for range rabbitReady {

			msgs, err := rabbitChan.Consume(
				"orders",
				"",
				true,
				false,
				false,
				false,
				nil,
			)

			if err != nil {
				log.Printf("Consume error: %v", err)
				continue
			}

			for msg := range msgs {
				orderID := getOrderId(msg.Body)
				go processOrder(orderID)
			}
		}
	}()

	log.Println("Dispatch service running...")
	select {}
}