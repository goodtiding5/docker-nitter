#!/bin/sh

set -eu

NITTER_TITLE="${NITTER_TITLE:-nitter}"
NITTER_HOST="${NITTER_HOST:-nitter.net}"
INVIDIOUS_HOST="${INVIDIOUS_HOST:-invidio.us}"
REDIS_HOST="${REDIS_HOST:-redis}"
REDIS_PORT="${REDIS_PORT:-6379}"

BUILD="/build"
WORKD="/data"

build_working_dir()
{
    [ -d $WORKD ]             || mkdir -p $WOKRD

    [ -d $WORKD/tmp ]         || mkdir -p $WORKD/tmp
    [ -d $WORKD/public ]      || cp -rf $BUILD/public      $WORKD/.

    chown -R www-data:www-data $WORKD
    chmod 777 $WORKD
}

construct_nitter_conf()
{
    [ -f $WORKD/nitter.conf ] && return

    cat /nitter.conf.pre > $WORKD/nitter.conf
    sed -i "s/REDIS_HOST/$REDIS_HOST/g; s/REDIS_PORT/$REDIS_PORT/g; s/NITTER_HOST/$NITTER_HOST/g; s/NITTER_TITLE/$NITTER_TITLE/g; s/INVIDIOUS_HOST/$INVIDIOUS_HOST/g; " $WORKD/nitter.conf
}

run_nitter_program()
{
    cd $WORKD
    exec gosu www-data:www-data /usr/local/bin/nitter
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
