FROM golang:1.15.5-alpine

RUN apk add git
RUN go get -u github.com/pkg/sftp golang.org/x/crypto/ssh

WORKDIR /app
