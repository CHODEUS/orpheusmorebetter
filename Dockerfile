FROM python:3.13-alpine

# Install runtime and build dependencies
RUN apk add --no-cache \
    git \
    mktorrent \
    flac \
    lame \
    sox \
    libxml2 \
    libxslt \
    openssl \
    # Build dependencies (will be removed later)
    && apk add --no-cache --virtual .build-deps \
    gcc \
    musl-dev \
    linux-headers \
    libxml2-dev \
    libxslt-dev \
    openssl-dev

WORKDIR /app
COPY requirements.txt /app/

# Install Python dependencies and remove build deps
RUN pip install --no-cache-dir -r requirements.txt \
    && apk del .build-deps

# Copy application files
COPY . /app

# Install the application
RUN pip install --no-cache-dir .

# Build arguments
ARG VERSION=dev
ARG GIT_BRANCH=main

# Create version files
RUN echo "v${VERSION}" > /app/version.txt \
    && echo "${GIT_BRANCH}" > /app/branch.txt

# Create non-root user with safe UID
RUN adduser -D -u 1000 -h /config orpheus \
    && mkdir -p /config /data /output /torrents \
    && chown -R orpheus:orpheus /app /config /data /output /torrents

# Make script executable
RUN chmod +x /app/orpheusmorebetter

# Switch to non-root user
USER orpheus

ENV HOME=/config

CMD ["/app/orpheusmorebetter"]
