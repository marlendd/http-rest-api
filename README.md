# HTTP REST API

REST API сервер на Go с аутентификацией через сессии.

## Возможности

- Регистрация пользователей
- Аутентификация через сессии (cookie-based)
- PostgreSQL для хранения данных
- Middleware для аутентификации
- Тесты с использованием teststore

## Требования

- Go 1.25+
- PostgreSQL
- migrate CLI (для миграций)

## Установка

```bash
# Клонировать репозиторий
git clone https://github.com/marlendd/http-rest-api.git
cd http-rest-api

# Установить зависимости
go mod download

# Создать базы данных
createdb restapi_dev
createdb restapi_test

# Применить миграции
migrate -path migrations -database "postgres://localhost/restapi_dev?sslmode=disable" up
```

## Конфигурация

Отредактируйте `configs/apiserver.toml`:

```toml
bind_addr = ":8080"
log_level = "debug"
database_url = "host=localhost dbname=restapi_dev sslmode=disable"
session_key = "your-secret-key-here"
```

## Запуск

### Локально (без Docker)

```bash
# Собрать
make build

# Запустить
./apiserver -config-path configs/apiserver.toml

# Или напрямую
go run ./cmd/apiserver -config-path configs/apiserver.toml
```

### С Docker Compose (рекомендуется)

```bash
# Запустить все сервисы (PostgreSQL + API)
docker-compose up -d

# Посмотреть логи
docker-compose logs -f api

# Остановить
docker-compose down

# Остановить и удалить данные
docker-compose down -v
```

### Только Docker (без compose)

```bash
# Собрать образ
docker build -t restapi:latest .

# Запустить контейнер
docker run -p 8080:8080 \
  -e DATABASE_URL="host=localhost dbname=restapi_dev sslmode=disable" \
  restapi:latest
```

## API Endpoints

### POST /users
Регистрация нового пользователя

```bash
http POST http://localhost:8080/users email=user@example.com password=password
```

### POST /sessions
Вход (создание сессии)

```bash
http POST http://localhost:8080/sessions email=user@example.com password=password
```

### GET /private/whoami
Получить информацию о текущем пользователе (требуется аутентификация)

```bash
http GET http://localhost:8080/private/whoami Cookie:marlend=<session-cookie>
```

## Тестирование

```bash
# Запустить все тесты
make test

# Запустить тесты с покрытием
go test -v -race -coverprofile=coverage.out ./...
go tool cover -html=coverage.out
```

## Структура проекта

```
.
├── cmd/
│   └── apiserver/          # Точка входа приложения
├── configs/                # Конфигурационные файлы
├── internal/
│   └── app/
│       ├── apiserver/      # HTTP сервер и handlers
│       ├── model/          # Модели данных
│       └── store/          # Слой работы с БД
│           ├── sqlstore/   # PostgreSQL реализация
│           └── teststore/  # In-memory реализация для тестов
└── migrations/             # SQL миграции
```

## Технологии

- [gorilla/mux](https://github.com/gorilla/mux) - HTTP роутер
- [gorilla/sessions](https://github.com/gorilla/sessions) - Управление сессиями
- [lib/pq](https://github.com/lib/pq) - PostgreSQL драйвер
- [ozzo-validation](https://github.com/go-ozzo/ozzo-validation) - Валидация
- [testify](https://github.com/stretchr/testify) - Тестирование

## Docker

**Быстрый старт:**
```bash
docker-compose up -d
```

Это запустит PostgreSQL, применит миграции и запустит API на порту 8080.

### Основные команды:

```bash
# Запустить
make docker-up

# Остановить
make docker-down

# Логи
make docker-logs

# Пересобрать после изменений
make docker-rebuild
```

### Архитектура:

- **Dockerfile** - многоступенчатая сборка для минимального размера образа
- **docker-compose.yml** - оркестрация всех сервисов (PostgreSQL, миграции, API)
- **.dockerignore** - исключение ненужных файлов из образа

### Что происходит при запуске docker-compose:

1. Поднимается PostgreSQL контейнер
2. Ждет готовности БД (healthcheck)
3. Запускаются миграции
4. Стартует API сервер

### Полезные команды:

```bash
# Подключиться к PostgreSQL
docker exec -it restapi_postgres psql -U postgres -d restapi_dev

# Зайти внутрь API контейнера
docker exec -it restapi_api sh

# Посмотреть логи конкретного сервиса
docker-compose logs -f postgres
docker-compose logs -f api

# Перезапустить только API
docker-compose restart api

# Удалить все (включая данные БД)
docker-compose down -v
```
