FROM golang:1.12 AS build

RUN mkdir  /test
WORKDIR    /test
COPY     . /test

RUN go build -o lt

ENTRYPOINT ["/test/lt"]
