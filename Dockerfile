FROM nimlang/nim:alpine as build

ARG  REPO=https://github.com/zedeus/nitter.git

RUN apk update \
&&  apk add libsass-dev \
        libffi-dev \
	openssl-dev \
	unzip \
	git
    
RUN set -x \
&&  mkdir /build && cd /build \
&&  git clone $REPO nitter \
&&  cd /build/nitter \
&&  nimble build -y -d:release --passC:"-flto" --passL:"-flto" \
&&  strip -s nitter \
&&  nimble scss

# ---------------------------------------------------------------------

FROM alpine:latest

LABEL maintainer="ken@epenguin.com"

RUN  apk --no-cache add \
     	 tini \
	 gosu \
	 pcre \
	 sqlite-libs \
	 curl

RUN  set -x; \
     addgroup -g 82 -S www-data ; \
     adduser -u 82 -D -S -G www-data www-data

RUN  mkdir -p /build /data \
&&   chown www-data:www-data /data \
&&   chmod 777 /data

COPY ./entrypoint.sh /entrypoint.sh
COPY --from=build /build/nitter/nitter /usr/local/bin
COPY --from=build /build/nitter/nitter.conf /build
COPY --from=build /build/nitter/public /build/public

WORKDIR /data
VOLUME  /data

EXPOSE  8080

HEALTHCHECK CMD curl --fail http://localhost:8080 || exit 1

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/entrypoint.sh"]
