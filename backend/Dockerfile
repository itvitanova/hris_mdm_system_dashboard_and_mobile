FROM golang:1.25-alpine AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
FROM build AS test
CMD ["sh", "-c", "go test -count=1 -v ./... && go vet ./..."]

FROM build AS binary
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /hris-api ./cmd/api && CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /hris-import ./cmd/import

FROM alpine:3.22
RUN apk add --no-cache ca-certificates tzdata && addgroup -S hris && adduser -S -G hris hris
COPY --from=binary /hris-api /usr/local/bin/hris-api
COPY --from=binary /hris-import /usr/local/bin/hris-import
USER hris
ENV LISTEN_ADDR=0.0.0.0:8080
EXPOSE 8080
CMD ["hris-api"]
