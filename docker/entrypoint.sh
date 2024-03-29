#!/bin/sh

## env vars to control nitter behavior

# -- for nitter 
NITTER_HOST_NAME=${NITTER_HOST_NAME:-"nitter.net"}
NITTER_TITLE=${NITTER_TITLE:-"Nitter"}
NITTER_ADDRESS=${NITTER_ADDRESS:-"0.0.0.0"}
NITTER_PORT=${NITTER_PORT:-8080}
NITTER_USE_HTTPS=${NITTER_USE_HTTPS:-false}
NITTER_MAX_CONNECTIONS=${NITTER_MAX_CONNECTIONS:-100}
NITTER_STATIC_DIR=${NITTER_STATIC_DIR:-"./public"}

# -- for cache
CACHE_LIST_MINUTES=${CACHE_LIST_MINUTES:-120}
CACHE_RSS_MINUTES=${CACHE_RSS_MINUTES:-10}
CACHE_REDIS_HOST=${CACHE_REDIS_HOST:-"localhost"}
CACHE_REDIS_PORT=${CACHE_REDIS_PORT:-6379}
CACHE_REDIS_PASSWORD=${CACHE_REDIS_PASSWORD:-""}
CACHE_REDIS_CONNECTIONS=${CACHE_REDIS_CONNECTIONS:-20}
CACHE_REDIS_MAXCONNECTIONS=${CACHE_REDIS_MAXCONNECTIONS:-30}

# -- for config
CONFIG_HMAC_KEY=${CONFIG_HMAC_KEY:-"s3cr3tk3y"}
CONFIG_BASE64_MEDIA=${CONFIG_BASE64_MEDIA:-false}
CONFIG_TOKEN_COUNT=${CONFIG_TOKEN_COUNT:-10}
CONFIG_ENABLE_RSS=${CONFIG_ENABLE_RSS:-true}
CONFIG_ENABLE_DEBUG=${CONFIG_ENABLE_DEBUG:-false}
CONFIG_PROXY=${CONFIG_PROXY:-""}
CONFIG_PROXY_AUTH=${CONFIG_PROXY_AUTH:-""}

# -- for preference
PREF_THEME=${PREF_THEME:-"Nitter"}
PREF_REPLACE_TWITTER=${PREF_REPLACE_TWITTER:-"nitter.net"}
PREF_REPLACE_YOUTUBE=${PREF_REPLACE_YOUTUBE:-"piped.video"}
PREF_REPLACE_REDDIT=${PREF_REPLACE_REDDIT:-"teddit.net"}
PREF_PROXY_VIDEOS=${PREF_PROXY_VIDEOS:-true}
PREF_HLS_PLAYBACK=${PREF_HLS_PLAYBACK:-false}
PREF_INFINITE_SCROLL=${PREF_INFINITE_SCROLL:-false}

set -eu

# construct config file
cat > nitter.conf <<EOF

[Server]
hostname = "${NITTER_HOST_NAME}"
title = "${NITTER_TITLE}"
address = "${NITTER_ADDRESS}"
port = ${NITTER_PORT}
https = ${NITTER_USE_HTTPS}
httpMaxConnections = ${NITTER_MAX_CONNECTIONS}
staticDir = "${NITTER_STATIC_DIR}"

[Cache]
listMinutes = ${CACHE_LIST_MINUTES}
rssMinutes = ${CACHE_RSS_MINUTES}
redisHost = "${CACHE_REDIS_HOST}"
redisPort = ${CACHE_REDIS_PORT}
redisPassword = "${CACHE_REDIS_PASSWORD}"
redisConnections = ${CACHE_REDIS_CONNECTIONS}
redisMaxConnections = ${CACHE_REDIS_MAXCONNECTIONS}

[Config]
hmacKey = "${CONFIG_HMAC_KEY}"
base64Media = ${CONFIG_BASE64_MEDIA}
enableRSS = ${CONFIG_ENABLE_RSS}
enableDebug = ${CONFIG_ENABLE_DEBUG}
proxy = "${CONFIG_PROXY}"
proxyAuth = "${CONFIG_PROXY_AUTH}"
tokenCount = ${CONFIG_TOKEN_COUNT}

[Preferences]
theme = "${PREF_THEME}"
replaceTwitter = "${PREF_REPLACE_TWITTER}"
replaceYouTube = "${PREF_REPLACE_YOUTUBE}"
replaceReddit = "${PREF_REPLACE_REDDIT}"
proxyVideos = ${PREF_PROXY_VIDEOS}
hlsPlayback = ${PREF_HLS_PLAYBACK}
infiniteScroll = ${PREF_INFINITE_SCROLL}

EOF

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
