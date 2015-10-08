#!/bin/sh

# see http://stackoverflow.com/a/3915420/318790
function realpath { echo $(cd $(dirname "$1"); pwd)/$(basename "$1"); }
__FILE__=`realpath "$0"`
__DIR__=`dirname "${__FILE__}"`

BASEDIR_PATH=$1

FFMPEG_SCRIPT_URL="https://github.com/jold/CocoaFFmpeg/archive/2.2.0.zip"
TARGET_PATH="${BASEDIR_PATH}/src"

if [ ! -d "$BASEDIR_PATH" ]; then
    mkdir -p "$BASEDIR_PATH"
fi

# download
function download() {
    "${__DIR__}/download.sh" "$1" "$2" #--no-cache
}

download ${FFMPEG_SCRIPT_URL} ${TARGET_PATH}