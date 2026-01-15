FROM alpine:3.14

RUN apk add --no-cache \
    git \
    gcc \
    musl-dev \
    linux-headers \
    mktorrent \
    flac \
    lame \
    sox \
    py3-lxml \
    py3-packaging \
    py3-pip \
    python3-dev \
    libxml2-dev \
    libxslt-dev \
    openssl-dev
