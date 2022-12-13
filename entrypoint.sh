#!/bin/sh

set -eu

NITTER_LISTEN_ADDRESS="${NITTER_LISTEN_ADDRESS:-"0.0.0.0"}"
NITTER_LISTEN_PORT="${NITTER_LISTEN_PORT:-"8080"}"
NITTER_USE_HTTPS="${NITTER_USE_HTTPS:-"false"}"
NITTER_MAX_CONNECTIONS="${NITTER_MAX_CONNECTIONS:-"100"}"
NITTER_STATIC_DIR="${NITTER_STATIC_DIR:-"./public"}"
NITTER_SERVER_TITLE="${NITTER_SERVER_TITLE:-"Nitter"}"
NITTER_SERVER_NAME="${NITTER_SERVER_NAME:-"nitter.net"}"
CACHE_LIST_MINUTES="${CACHE_LIST_MINUTES:-"120"}"
CACHE_RSS_MINUTES="${CACHE_RSS_MINUTES:-"10"}"
CACHE_REDIS_HOST="${CACHE_REDIS_HOST:-"localhost"}"
CACHE_REDIS_PORT="${CACHE_REDIS_PORT:-"6379"}"
CACHE_REDIS_CONNECTIONS="${CACHE_REDIS_CONNECTIONS:-"20"}"
CACHE_REDIS_MAXCONNECTIONS="${CACHE_REDIS_MAXCONNECTIONS:-"30"}"
CACHE_REDIS_PASSWORD="${CACHE_REDIS_PASSWORD:-""}"
CONFIG_HMAC_KEY="${CONFIG_HMAC_KEY:-"secretkey"}"
CONFIG_BASE64_MEDIA="${CONFIG_BASE64_MEDIA:-"false"}"
CONFIG_TOKEN_COUNT="${CONFIG_TOKEN_COUNT:-"10"}"
CONFIG_ENABLE_RSS="${CONFIG_ENABLE_RSS:-"true"}"
CONFIG_ENABLE_DEBUG="${CONFIG_ENABLE_DEBUG:-"false"}"
CONFIG_PROXY="${CONFIG_PROXY:-""}"
CONFIG_PROXY_AUTH="${CONFIG_PROXY_AUTH:-""}"
     
DIST="/dist"
DATA="/data"

build_working_dir()
{
    mkdir -p $DATA/tmp || exit 1
    mkdir -p $DATA/public || exit 1

    cp -r -f  $DIST/public/* $DATA/public/.
}

setup_nitter_conf()
{
    if [ ! -f $DATA/nitter.conf ]; then
        if [ -f /dist/nitter.example.conf ]; then
            cp /dist/nitter.example.conf $DATA/nitter.conf
        else
            curl -f -L https://raw.githubusercontent.com/zedeus/nitter/master/nitter.example.conf > $DATA/nitter.conf
        fi
    fi
}

run_nitter_program()
{
    cd $DATA
    exec /usr/local/bin/nitter
}

# -- program starts

build_working_dir
setup_nitter_conf

if [[ $@ ]]; then 
    case "$1" in
	"init")
	    # workdir is prepared by now
	    ;;
	
	"nitter")
	    run_nitter_program;;
	
	*)
	    eval "exec $@";;
    esac
else
    run_nitter_program
fi

exit 0
