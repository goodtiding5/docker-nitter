#!/bin/sh

set -e
set -u

NITTER_HOST=${NITTER_HOST:-localhost}
REDIS_HOST=${REDIS_HOST:-redis}
REDIS_PORT=${REDIS_PORT:-6379}

BUILD=/build
WORKD=/data

build_working_dir() {
    [ -d $WORKD ]             || mkdir -p $WOKRD

    [ -d $WORKD/tmp ]         || mkdir -p $WORKD/tmp
    [ -d $WORKD/public ]      || cp -rf $BUILD/public      $WORKD/.

    chown -R www-data:www-data $WORKD
    chmod 777 $WORKD
}

construct_nitter_conf() {
    [ -f $WORKD/nitter.conf ] && return

    cat /nitter.conf.pre > $WORKD/nitter.conf
    sed -i "s/REDIS_HOST/$REDIS_HOST/g; s/REDIS_PORT/$REDIS_PORT/g" $WORKD/nitter.conf
}

run_nitter_program() {
    cd $WORKD
    exec gosu www-data:www-data /usr/local/bin/nitter
}

# -- program starts

build_working_dir
construct_nitter_conf

if [[ $@ ]]; then 
    case "$1" in
	"bootstrap")
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
