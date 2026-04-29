# Build stage
FROM golang:1.23 AS builder

WORKDIR /go/src/app

COPY go.mod go.sum ./
RUN go mod download

COPY *.go ./

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o dispatch .

# Production image
FROM scratch

WORKDIR /app

# Expose metrics port
EXPOSE 9090

COPY --from=builder /go/src/app/dispatch .

CMD ["/app/dispatch"]