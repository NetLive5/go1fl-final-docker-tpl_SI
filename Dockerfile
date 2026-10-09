FROM golang:1.25 AS build

WORKDIR /src

COPY go.mod go.sum ./
RUN go mod download

COPY *.go tracker.db ./
RUN CGO_ENABLED=0 go test ./...
RUN mkdir -p /out/app \
    && CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /out/app/parcel-tracker .

FROM scratch

COPY --from=build --chown=10001:10001 /out/ /
WORKDIR /app
COPY --chown=10001:10001 tracker.db ./

USER 10001:10001
ENTRYPOINT ["/app/parcel-tracker"]
