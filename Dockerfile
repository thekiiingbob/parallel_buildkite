FROM node:8-alpine

RUN mkdir -p /app
WORKDIR /app

RUN apk add --no-cache bash git curl jq
RUN base=https://github.com/docker/machine/releases/download/v0.14.0 && curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine && install /tmp/docker-machine /usr/local/bin/docker-machine