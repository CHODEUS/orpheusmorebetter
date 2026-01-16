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
    su-exec \
    && apk add --no-cache --virtual .build-deps \
    gcc \
    musl-dev \
    linux-headers \
    libxml2-dev \
    libxslt-dev \
    openssl-dev

WORKDIR /app
COPY requirements.txt /app/

RUN pip install --no-cache-dir -r requirements.txt \
    && apk del .build-deps

COPY . /app
RUN pip install --no-cache-dir .

ARG VERSION=dev
ARG GIT_BRANCH=main

RUN echo "v${VERSION}" > /app/version.txt \
    && echo "${GIT_BRANCH}" > /app/branch.txt

# Create directories with permissive permissions (will be fixed by start.sh)
RUN mkdir -p /config /data /output /torrents

# Make scripts executable
RUN chmod +x /app/orpheusmorebetter /app/start.sh

# Default values for Unraid (nobody:users)
ENV PUID=99 \
    PGID=100 \
    UMASK=002

# Container starts as root, start.sh handles user switching
CMD ["/app/start.sh"]
