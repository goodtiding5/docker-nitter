#!/bin/sh

set -eux

cd /app

# -- prepare running environment

if [ ! -f nitter.conf ]; then
    unzip /dist.zip
    cp nitter.example.conf nitter.conf
fi

# -- program starts

if [[ $@ ]]; then 
    case "$1" in
	"nitter")
	    exec /usr/local/bin/nitter;;
	
	*)
	    eval "exec $@";;
    esac
else
    exec /usr/local/bin/nitter
fi

exit 0
