# Многоступенчатая сборка для минимального размера образа

# Этап 1: Сборка приложения
FROM golang:1.25-alpine AS builder

RUN apk add --no-cache git

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o apiserver ./cmd/apiserver

# Этап 2: Финальный образ
FROM alpine:latest

# Добавляем CA сертификаты для HTTPS
RUN apk --no-cache add ca-certificates

WORKDIR /root/

COPY --from=builder /app/apiserver .
COPY --from=builder /app/configs ./configs

EXPOSE 8080

# Запуск приложения
CMD ["./apiserver", "-config-path", "configs/apiserver.toml"]
