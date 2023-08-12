FROM nimlang/nim:alpine as build

ARG REPO=https://github.com/goodtiding5/nitter.git
ARG BRANCH=develop

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
&&  git clone -b $BRANCH $REPO . \
&&  nimble install -y --depsOnly \
&&  nimble build -y -d:danger -d:lto \
&&  strip -s nitter \
&&  nimble scss \
&&  nimble md

# ---------------------------------------------------------------------

FROM alpine:3.17

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
     CONFIG_PROXY_AUTH="" \
     PREF_NITTER_THEME="Nitter" \
     PREF_REPLACE_TWITTER="nitter.net" \
     PREF_REPLACE_YOUTUBE="piped.video" \
     PREF_REPLACE_REDDIT="teddit.net" \
     PREF_PROXY_VIDEOS=true \
     PREF_HLS_PLAYBACK=false \
     PREF_INFINITE_SCROLL=false
     
COPY ./entrypoint.sh /entrypoint.sh

COPY --from=build /build/nitter /usr/local/bin
COPY --from=build /build/public /data/public
COPY --from=build /build/nitter.example.conf /data/nitter.conf

RUN set -eux \
&&  (getent group www-data || addgroup -g 82 www-data) \
&&  (getent passwd www-data || adduser -u 82 -G www-data -h /data -D www-data) \
&&  apk add --no-cache curl pcre \
&&  chown root:root /entrypoint.sh /usr/local/bin/nitter \
&&  chmod 0555 /entrypoint.sh /usr/local/bin/nitter \
&&  chown -R www-data:www-data /data

WORKDIR /data

EXPOSE  8080

USER www-data

HEALTHCHECK CMD curl --fail http://localhost:8080 || exit 1

ENTRYPOINT ["/entrypoint.sh"]
CMD ["nitter"]
