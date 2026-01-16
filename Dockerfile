FROM python:3.13-alpine AS builder

RUN apk add --no-cache \
    gcc \
    musl-dev \
    linux-headers \
    libxml2-dev \
    libxslt-dev \
    openssl-dev

WORKDIR /build

COPY requirements.txt .
RUN pip wheel --no-cache-dir --no-deps --wheel-dir /wheels -r requirements.txt

COPY . .
RUN pip wheel --no-cache-dir --no-deps --wheel-dir /wheels .

FROM python:3.13-alpine

RUN apk add --no-cache \
    git \
    mktorrent \
    flac \
    lame \
    sox \
    libxml2 \
    libxslt \
    openssl \
    shadow \
    su-exec

WORKDIR /app

COPY --from=builder /wheels /wheels

RUN pip install --no-cache-dir /wheels/* \
    && rm -rf /wheels

COPY . /app

ARG VERSION=dev
ARG GIT_BRANCH=main

RUN echo "v${VERSION}" > /app/version.txt \
    && echo "${GIT_BRANCH}" > /app/branch.txt

RUN mkdir -p /config /data /output /torrents

RUN chmod +x /app/orpheusmorebetter /app/start.sh

LABEL org.opencontainers.image.title="OrpheusMoreBetter" \
      org.opencontainers.image.description="Automatic transcode helper for Orpheus Network" \
      org.opencontainers.image.authors="CHODEUS" \
      org.opencontainers.image.source="https://github.com/CHODEUS/orpheusmorebetter" \
      org.opencontainers.image.version="${VERSION}"

ENV PUID=99 \
    PGID=100 \
    UMASK=002

CMD ["/app/start.sh"]
