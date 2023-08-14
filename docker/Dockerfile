FROM nimlang/nim:alpine as build

ARG REPO=https://github.com/zedeus/nitter.git
ARG BRANCH=master

RUN apk update \
&&  apk add libsass-dev \
        libffi-dev \
	openssl-dev \
	pcre \
	zip \
	git \
&&  mkdir -p /build

WORKDIR /build

# build nitter    
RUN set -ex \
&&  git clone -b $BRANCH $REPO . \
&&  nimble install -y --depsOnly \
&&  nimble build -y -d:danger -d:lto \
&&  strip -s nitter \
&&  nimble scss \
&&  nimble md


# ---------------------------------------------------------------------

FROM alpine:3.18


LABEL maintainer="ken@epenguin.com"

# -- for nitter 
ENV NITTER_HOST_NAME="nitter.net" \
    NITTER_TITLE="Nitter" \
    NITTER_ADDRESS="0.0.0.0" \
    NITTER_PORT=8080 \
    NITTER_USE_HTTPS=false \
    NITTER_MAX_CONNECTIONS=100 \
    NITTER_STATIC_DIR="./public"

# -- for cache
ENV CACHE_LIST_MINUTES=120 \
    CACHE_RSS_MINUTES=10 \
    CACHE_REDIS_HOST="localhost" \
    CACHE_REDIS_PORT=6379 \
    CACHE_REDIS_PASSWORD="" \
    CACHE_REDIS_CONNECTIONS=20 \
    CACHE_REDIS_MAXCONNECTIONS=30

# -- for config
ENV CONFIG_HMAC_KEY="s3cr3tk3y" \
    CONFIG_BASE64_MEDIA=false \
    CONFIG_TOKEN_COUNT=10 \
    CONFIG_ENABLE_RSS=true \
    CONFIG_ENABLE_DEBUG=false \
    CONFIG_PROXY="" \
    CONFIG_PROXY_AUTH=""

# -- for preference
ENV PREF_THEME="Nitter" \
    PREF_REPLACE_TWITTER="nitter.net" \
    PREF_REPLACE_YOUTUBE="piped.video" \
    PREF_REPLACE_REDDIT="teddit.net" \
    PREF_PROXY_VIDEOS=true \
    PREF_HLS_PLAYBACK=false \
    PREF_INFINITE_SCROLL=false


RUN set -eux \
&&  (getent group www-data || addgroup -g 82 www-data) \
&&  (getent passwd www-data || adduser -u 82 -G www-data -h /data -D www-data) \
&&  apk add --no-cache curl pcre

COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
COPY --from=build /build/nitter /usr/local/bin
COPY --from=build /build/nitter.example.conf /data/
COPY --from=build /build/public /data/public

RUN set -eux \
&&  chown root:root /usr/local/bin/entrypoint.sh /usr/local/bin/nitter \
&&  chmod 0555 /usr/local/bin/entrypoint.sh /usr/local/bin/nitter \
&&  chown -R www-data:www-data /data

WORKDIR /data

EXPOSE 8080

USER www-data

HEALTHCHECK CMD curl --fail http://localhost:8080 || exit 1

ENTRYPOINT ["entrypoint.sh"]
CMD ["nitter"]
