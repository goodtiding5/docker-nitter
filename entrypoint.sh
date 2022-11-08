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
    [ -d $DATA ]             || mkdir -p $DATA
    [ -d $DATA/tmp ]         || mkdir -p $DATA/tmp
    [ -d $DATA/public ]      || cp -rf   $DIST/public $DATA/.

    chown -R www-data:www-data $DATA
    chmod 777 $DATA
}

construct_nitter_conf()
{
    if [ ! -f $DATA/nitter.conf ]; then
	cat /dist/nitter.conf.pre \
	    | sed "s/REDIS_HOST/$REDIS_HOST/g" \
	    | sed "s/REDIS_PORT/$REDIS_PORT/g" \
	    | sed "s/REDIS_PASS/$REDIS_PASS/g" \
	    | sed "s/NITTER_HTTPS/$NITTER_HTTPS/g" \
	    | sed "s/NITTER_HOST/$NITTER_HOST/g" \
	    | sed "s/NITTER_NAME/$NITTER_NAME/g" \
	    | sed "s/NITTER_THEME/$NITTER_THEME/g" \
  	    | sed "s/NITTER_SECRET/$NITTER_SECRET/g" \
	    | sed "s/REPLACE_TWITTER/$REPLACE_TWITTER/g" \
	    | sed "s/REPLACE_YOUTUBE/$REPLACE_YOUTUBE/g" \
	    | sed "s/REPLACE_REDDIT/$REPLACE_REDDIT/g" \
	    | sed "s/REPLACE_INSTAGRAM/$REPLACE_INSTAGRAM/g" > $DATA/nitter.conf
    fi
    chown www-data:www-data $DATA/nitter.conf
}

run_nitter_program()
{
    cd $DATA
    exec su-exec www-data:www-data /usr/local/bin/nitter
}

# -- program starts

build_working_dir
construct_nitter_conf

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
