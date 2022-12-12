#!/bin/sh

set -eu

REDIS_HOST="${REDIS_HOST:-redis}"
REDIS_PORT="${REDIS_PORT:-6379}"
REDIS_PASS="${REDIS_PASS:-\"\"}"
NITTER_HTTPS="${NITTER_HTTPS:-false}"
NITTER_HOST="${NITTER_HOST:-nitter.net}"
NITTER_NAME="${NITTER_NAME:-nitter}"
NITTER_SECRET="${NITTER_SECRET:-secretKey}"
NITTER_THEME="${NITTER_THEME:-Nitter}"
REPLACE_TWITTER="${REPLACE_TWITTER:-nitter.net}"
REPLACE_YOUTUBE="${REPLACE_YOUTUBE:-piped.kavin.rocks}"
REPLACE_REDDIT="${REPLACE_REDDIT:-teddit.net}"
REPLACE_INSTAGRAM="${REPLACE_INSTAGRAM:-""}"

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
    if [ -f $DATA/nitter.conf ]; then
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
