FROM node:8-alpine

RUN mkdir -p /app
WORKDIR /app

RUN apk add --no-cache bash git jq