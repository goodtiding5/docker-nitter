#!/bin/sh

set -e
set -u

BUILD=/build
WORKD=/data

build_working_dir() {
    [ -d $WORKD ]             || mkdir -p $WOKRD

    [ -d $WORKD/tmp ]         || mkdir -p $WORKD/tmp
    [ -f $WORKD/nitter.conf ] || cp -f  $BUILD/nitter.conf $WORKD/.
    [ -d $WORKD/public ]      || cp -rf $BUILD/public      $WORKD/.

    chown -R www-data:www-data $WORKD
    chmod 777 $WORKD
}

run_nitter_program() {
    cd $WORKD
    exec gosu www-data:www-data /usr/local/bin/nitter
}

# -- program starts

build_working_dir

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
