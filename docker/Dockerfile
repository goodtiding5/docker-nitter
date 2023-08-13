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

# create dist file
RUN zip -r /dist.zip ./public ./nitter.example.conf

# ---------------------------------------------------------------------

FROM alpine:3.18

ARG UID=1000
ARG GID=1000

LABEL maintainer="ken@epenguin.com"

COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh

COPY --from=build /build/nitter /usr/local/bin
COPY --from=build /dist.zip /dist.zip

RUN set -eux \
&&  (getent group nitter || addgroup -g ${GID} nitter) \
&&  (getent passwd nitter|| adduser -u ${UID} -G nitter -h /app -D nitter) \
&&  apk add --no-cache curl pcre \
&&  chown root:root /usr/local/bin/entrypoint.sh /usr/local/bin/nitter \
&&  chmod 0555 /usr/local/bin/entrypoint.sh /usr/local/bin/nitter \
&&  chown -R ${UID}:${GID} /app

WORKDIR /app

EXPOSE 8080

USER nitter

HEALTHCHECK CMD curl --fail http://localhost:8080 || exit 1

ENTRYPOINT ["entrypoint.sh"]
CMD ["nitter"]
