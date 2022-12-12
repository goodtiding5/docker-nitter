FROM nimlang/nim:alpine as build

ARG  REPO=https://github.com/zedeus/nitter.git

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

ENV  REDIS_HOST="localhost" \
     REDIS_PASS="" \
     REDIS_PORT=6379 \
     NITTER_HTTPS="false" \
     NITTER_HOST="nitter.net" \
     NITTER_NAME="nitter" \
     NITTER_THEME="Nitter" \
     NITTER_SECRET="my+secret+key" \
     REPLACE_TWITTER="nitter.net" \
     REPLACE_YOUTUBE="piped.kavin.rocks" \
     REPLACE_REDDIT="teddit.net" \
     REPLACE_INSTAGRAM=""

RUN set -eux \
&&  (getent group www-data || addgroup -g 82 www-data) \
&&  (getent passwd www-data || adduser -u 82 -G www-data -h /data -D www-data) \
&&  apk add --no-cache curl pcre

COPY ./entrypoint.sh /entrypoint.sh
COPY ./nitter.conf.pre /dist/nitter.conf.pre

COPY --from=build /build/nitter /usr/local/bin
COPY --from=build /build/public /dist/public

WORKDIR /data
VOLUME  /data

EXPOSE  8080

USER www-data

HEALTHCHECK CMD curl --fail http://localhost:8080 || exit 1

ENTRYPOINT ["/entrypoint.sh"]
