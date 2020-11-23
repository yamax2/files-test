FROM golang:1.15.5-alpine as builder

RUN mkdir /app
COPY test.go /app/test.go
RUN cd /app && go build -ldflags '-s -w' test.go

FROM nginx:alpine

RUN apk add --update --no-cache mc htop
RUN mkdir -p /app/info
RUN echo '<h1>Here!</h1>' > /app/info/index.html
COPY --from=builder /app/test /app/test
COPY proxy.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD nginx && /app/test
