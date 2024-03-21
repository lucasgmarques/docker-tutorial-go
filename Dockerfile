##
## Build
##

FROM golang:1.16-buster AS build-stage

WORKDIR /app

COPY go.mod .
COPY go.sum .
RUN go mod download

COPY *.go ./

RUN CGO_ENABLED=0 GOOS=linux go build -o /docker-gs-ping-roach

# Run the tests in the container
FROM build-stage AS run-test-stage
RUN go test -v ./...

##
## Deploy
##

FROM gcr.io/distroless/base-debian10

WORKDIR /

COPY --from=build-stage /docker-gs-ping-roach /docker-gs-ping-roach

EXPOSE 8080

USER nonroot:nonroot

ENTRYPOINT ["/docker-gs-ping-roach"]
