FROM node:8-alpine

RUN mkdir -p /app
WORKDIR /app

RUN apk add --no-cache bash git curl jq
RUN curl -L https://github.com/docker/machine/releases/download/v0.14.0/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine
RUN install /tmp/docker-machine /usr/local/bin/docker-machine
RUN curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
RUN chmod +x /usr/local/bin/docker-compose