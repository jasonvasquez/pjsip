#!/bin/sh

# see http://stackoverflow.com/a/3915420/318790
function realpath { echo $(cd $(dirname "$1"); pwd)/$(basename "$1"); }
__FILE__=`realpath "$0"`
__DIR__=`dirname "${__FILE__}"`

BUILD_DIR="$1"
DIST_DIR="$2"

#re-create dist dir
rm -rf "$DIST_DIR"

if [ ! -d ${DIST_DIR} ]; then
    mkdir "${DIST_DIR}"
    mkdir "${DIST_DIR}/include"
    mkdir "${DIST_DIR}/lib"
fi

#Copy libs
cp $BUILD_DIR/openh264/lib/*.a "$DIST_DIR/lib"
cp $BUILD_DIR/pjproject/src/lib/*.a "$DIST_DIR/lib"

#Copy includes
cp -R $BUILD_DIR/pjproject/src/pjlib/include/* "$DIST_DIR/include"
cp -R $BUILD_DIR/pjproject/src/pjlib-util/include/* "$DIST_DIR/include"
cp -R $BUILD_DIR/pjproject/src/pjmedia/include/* "$DIST_DIR/include"
cp -R $BUILD_DIR/pjproject/src/pjnath/include/* "$DIST_DIR/include"
cp -R $BUILD_DIR/pjproject/src/pjsip/include/* "$DIST_DIR/include"