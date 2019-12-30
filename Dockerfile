FROM nimlang/nim:alpine as build

ADD  https://github.com/zedeus/nitter/archive/master.zip /src/download/

WORKDIR /src

RUN apk update \
    && apk add libsass-dev libffi-dev openssl-dev unzip \
    && unzip /src/download/master.zip \
    && mv nitter-master nitter \
    && cd nitter \
    && nimble build -y -d:release --passC:"-flto" --passL:"-flto" \
    && strip -s nitter \
    && nimble scss

FROM alpine:latest

LABEL maintainer="ken@epenguin.com"

RUN apk --no-cache add tini pcre sqlite-libs curl \
&&  mkdir -p /build

COPY ./entrypoint.sh /entrypoint.sh
COPY --from=build /src/nitter/nitter /usr/local/bin
COPY --from=build /src/nitter/nitter.conf /build
COPY --from=build /src/nitter/public /build/public

EXPOSE  8080
WORKDIR /data
VOLUME  /data

HEALTHCHECK CMD curl --fail http://localhost:8080 || exit 1

ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]
CMD ["nitter"]
