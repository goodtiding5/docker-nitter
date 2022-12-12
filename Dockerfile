FROM nimlang/nim:alpine as build

ARG  REPO=https://github.com/goodtiding5/nitter.git

RUN apk update \
&&  apk add libsass-dev \
        libffi-dev \
	openssl-dev \
	pcre \
	unzip \
	git \
&&  mkdir -p /build

WORKDIR /build
    
RUN set -ex \
&&  git clone $REPO . \
&&  nimble install -y --depsOnly \
&&  nimble build -y -d:release --passC:"-flto" --passL:"-flto" \
&&  strip -s nitter \
&&  nimble scss \
&&  nimble md

# ---------------------------------------------------------------------

FROM alpine:3.16

LABEL maintainer="ken@epenguin.com"

ENV  NITTER_LISTEN_ADDRESS="0.0.0.0" \
     NITTER_LISTEN_PORT=8080 \
     NITTER_USE_HTTPS=false \
     NITTER_MAX_CONNECTIONS=100 \
     NITTER_STATIC_DIR="./public" \
     NITTER_SERVER_TITLE="Nitter" \
     NITTER_SERVER_NAME="nitter.net" \
     CACHE_LIST_MINUTES=120 \
     CACHE_RSS_MINUTES=10 \
     CACHE_REDIS_HOST="localhost" \
     CACHE_REDIS_PORT=6379 \
     CACHE_REDIS_CONNECTIONS=20 \
     CACHE_REDIS_MAXCONNECTIONS=30 \
     CACHE_REDIS_PASSWORD="" \
     CONFIG_HMAC_KEY="secretkey" \
     CONFIG_BASE64_MEDIA=false \
     CONFIG_TOKEN_COUNT=10 \
     CONFIG_ENABLE_RSS=true \
     CONFIG_ENABLE_DEBUG=false \
     CONFIG_PROXY="" \
     CONFIG_PROXY_AUTH=""
     
COPY ./entrypoint.sh /entrypoint.sh

RUN set -eux \
&&  chown root:root /entrypoint.sh \
&&  chmod 0555 /entrypoint.sh \
&&  (getent group www-data || addgroup -g 82 www-data) \
&&  (getent passwd www-data || adduser -u 82 -G www-data -h /data -D www-data) \
&&  apk add --no-cache curl pcre

COPY --from=build /build/nitter /usr/local/bin
COPY --from=build /build/public /dist/public

ADD  https://raw.githubusercontent.com/goodtiding5/nitter/master/nitter.example.conf /dist

WORKDIR /data
VOLUME  /data

EXPOSE  8080

USER www-data

HEALTHCHECK CMD curl --fail http://localhost:8080 || exit 1

ENTRYPOINT ["/entrypoint.sh"]
