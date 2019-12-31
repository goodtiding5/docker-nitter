#!/bin/sh

set -e
set -u

BUILD=/build
WORKD=/data

build_working_dir() {
    [ -d $WORKD/tmp ]         || mkdir -p $WORKD/tmp
    [ -f $WORKD/nitter.conf ] || cp -f  $BUILD/nitter.conf $WORKD/.
    [ -d $WORKD/public ]      || cp -rf $BUILD/public      $WORKD/.
}

run_nitter_program() {
    cd $WORKD
    exec /usr/local/bin/nitter
}

# -- program starts

build_working_dir

cmd="nitter"

if [ $# -gt 0 ]; then
    cmd=$1
fi

case "$cmd" in
    "bootstrap")
	# workdir is prepared by now
	exit 0;;
    "nitter")
	run_nitter_program;;
    *)
	eval "exec $@";;
esac

exit 0
