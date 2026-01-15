FROM python:3.13-alpine

RUN apk add --no-cache \
    git \
    gcc \
    musl-dev \
    linux-headers \
    mktorrent \
    flac \
    lame \
    sox \
    libxml2-dev \
    libxslt-dev \
    openssl-dev

WORKDIR /app

COPY . /app

RUN chmod +x /app/orpheusmorebetter

RUN pip install --no-cache-dir -r requirements.txt \
 && pip install --no-cache-dir .

ARG VERSION=dev
ARG GIT_BRANCH=main
RUN echo "v${VERSION}" > /app/version.txt \
 && echo "${GIT_BRANCH}" > /app/branch.txt

RUN adduser -D -u 99 -h /config orpheus \
 && mkdir -p /config /data /output /torrents \
 && chown -R orpheus:orpheus /app /config /data /output /torrents

USER orpheus

ENV HOME=/config

CMD ["/app/orpheusmorebetter"]