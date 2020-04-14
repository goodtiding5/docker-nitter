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

FROM alpine:latest as bootstrap

ENV GOSU_VERSION 1.11
RUN set -eux; \
	\
	apk add --no-cache --virtual .gosu-deps \
		ca-certificates \
		dpkg \
		gnupg \
	; \
	\
	dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
	wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
	wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
	\
# verify the signature
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
	gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
	command -v gpgconf && gpgconf --kill all || :; \
	rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc; \
	\
# clean up fetch dependencies
	apk del --no-network .gosu-deps; \
	\
	chmod +x /usr/local/bin/gosu; \
# verify that the binary works
	gosu --version; \
	gosu nobody true

# ---------------------------------------------------------------------

FROM alpine:latest

LABEL maintainer="ken@epenguin.com"

RUN  apk --no-cache add \
     	 tini \
	 pcre \
	 sqlite-libs \
	 curl

COPY ./entrypoint.sh /entrypoint.sh

RUN  set -x; \
     addgroup -g 82 -S www-data; \
     adduser -u 82 -D -S -G www-data www-data \
&&   mkdir -p /build /data; \
     chown www-data:www-data /data; \
     chmod 777 /data \
&&   chmod 0555 /entrypoint.sh

COPY --from=build /build/nitter/nitter /usr/local/bin
COPY --from=build /build/nitter/nitter.conf /build
COPY --from=build /build/nitter/public /build/public
COPY --from=bootstrap /usr/local/bin/gosu /usr/bin/gosu

WORKDIR /data
VOLUME  /data

EXPOSE  8080

HEALTHCHECK CMD curl --fail http://localhost:8080 || exit 1

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/entrypoint.sh"]
