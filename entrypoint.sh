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

# If we have an interactive container session
if [[ -t 0 || -p /dev/stdin ]]; then
    if [[ $@ ]]; then 
	eval "exec $@"
    else 
	export PS1='[\u@\h : \w]\$ '
	exec /bin/sh
    fi
# If container is detached run nitter in the foreground
else
    if [ -z $1 ]; then
	run_nitter_program
    else
	case "$1" in
	    "bootstrap")
		# workdir is prepared
		exit 0;;
	    "nitter")
		run_nitter_program;;
	    *)
		eval "exec $@";;
	esac
    fi
fi
