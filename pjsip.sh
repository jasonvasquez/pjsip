#!/bin/sh

# see http://stackoverflow.com/a/3915420/318790
function realpath { echo $(cd $(dirname "$1"); pwd)/$(basename "$1"); }
__FILE__=`realpath "$0"`
__DIR__=`dirname "${__FILE__}"`

# download
function download() {
    "${__DIR__}/download.sh" "$1" "$2" #--no-cache
}

NUMCORES=`sysctl -n hw.logicalcpu`

BASE_DIR="$1"
PJSIP_URL="http://www.pjsip.org/release/2.4.5/pjproject-2.4.5.tar.bz2"
PJSIP_DIR="$1/src"
LIB_PATHS=("pjlib/lib" \
           "pjlib-util/lib" \
           "pjmedia/lib" \
           "pjnath/lib" \
           "pjsip/lib" \
           "third_party/lib")

LIPO_LIB_SUFFIX="apple-darwin_ios.a"
LIPO_ARCHS=("armv7" \
            "armv7s" \
            "arm64" \
            "i386" \
            "x86_64")

LIPO_LIBS=("pjlib/lib-ARCH/libpj" \
           "pjlib-util/lib-ARCH/libpjlib-util" \
           "pjmedia/lib-ARCH/libpjmedia" \
           "pjmedia/lib-ARCH/libpjmedia" \
           "pjmedia/lib-ARCH/libpjmedia-audiodev" \
           "pjmedia/lib-ARCH/libpjmedia-codec" \
           "pjmedia/lib-ARCH/libpjmedia-videodev" \
           "pjmedia/lib-ARCH/libpjsdp" \
           "pjnath/lib-ARCH/libpjnath" \
           "pjsip/lib-ARCH/libpjsip" \
           "pjsip/lib-ARCH/libpjsip-simple" \
           "pjsip/lib-ARCH/libpjsip-ua" \
           "pjsip/lib-ARCH/libpjsua" \
           "pjsip/lib-ARCH/libpjsua2" \
           "third_party/lib-ARCH/libg7221codec" \
           "third_party/lib-ARCH/libgsmcodec" \
           "third_party/lib-ARCH/libilbccodec" \
           "third_party/lib-ARCH/libresample" \
           "third_party/lib-ARCH/libspeex" \
           "third_party/lib-ARCH/libsrtp")

OPENSSL_PREFIX=
OPENH264_PREFIX=
FFMPEG_PREFIX=
while [ "$#" -gt 0 ]; do
    case $1 in
        --with-openssl)
            if [ "$#" -gt 1 ]; then
                OPENSSL_PREFIX=$2
                shift 2
                continue
            else
                echo 'ERROR: Must specify a non-empty "--with-openssl PREFIX" argument.' >&2
                exit 1
            fi
            ;;
        --with-openh264)
            if [ "$#" -gt 1 ]; then
                OPENH264_PREFIX=$2
                shift 2
                continue
            else
                echo 'ERROR: Must specify a non-empty "--with-openh264 PREFIX" argument.' >&2
                exit 1
            fi
            ;;
        --with-ffmpeg)
            if [ "$#" -gt 1 ]; then
                FFMPEG_PREFIX=$2
                shift 2
                continue
            else
                echo 'ERROR: Must specify a non-empty "--with-ffmpeg PREFIX" argument.' >&2
                exit 1
            fi
            ;;
    esac

    shift
done

function config_site() {
    SOURCE_DIR=$1
    PJSIP_CONFIG_PATH="${SOURCE_DIR}/pjlib/include/pj/config_site.h"
    HAS_VIDEO=

    echo "Creating config_site.h..."

    if [ -f "${PJSIP_CONFIG_PATH}" ]; then
        rm "${PJSIP_CONFIG_PATH}"
    fi

    echo "#define PJ_CONFIG_IPHONE 1" >> "${PJSIP_CONFIG_PATH}"
    if [[ ${OPENH264_PREFIX} ]]; then
        echo "#define PJMEDIA_HAS_OPENH264_CODEC 1" >> "${PJSIP_CONFIG_PATH}"
        HAS_VIDEO=1
    fi
    if [[ ${HAS_VIDEO} ]]; then
        echo "#define PJMEDIA_HAS_VIDEO 1" >> "${PJSIP_CONFIG_PATH}"
        echo "#define PJMEDIA_VIDEO_DEV_HAS_OPENGL 1" >> "${PJSIP_CONFIG_PATH}"
        echo "#define PJMEDIA_VIDEO_DEV_HAS_OPENGL_ES 1" >> "${PJSIP_CONFIG_PATH}"
        echo "#define PJMEDIA_VIDEO_DEV_HAS_IOS_OPENGL 1" >> "${PJSIP_CONFIG_PATH}"
        echo "#include <OpenGLES/ES3/glext.h>" >> "${PJSIP_CONFIG_PATH}"
    fi
    echo "#include <pj/config_site_sample.h>" >> "${PJSIP_CONFIG_PATH}"
}

function copy_libs () {
    ARCH=${1}

    for SRC_DIR in ${LIB_PATHS[*]}; do
        SRC_DIR="${PJSIP_DIR}/${SRC_DIR}"
        DST_DIR="${SRC_DIR}-${ARCH}"
        if [ -d "${DST_DIR}" ]; then
            rm -rf "${DST_DIR}"
        fi
        cp -R "${SRC_DIR}" "${DST_DIR}"
    done
}

function _build() {
    pushd . > /dev/null
    cd ${PJSIP_DIR}

    ARCH=$1
    LOG=${BASE_DIR}/${ARCH}.log

    # configure
    CONFIGURE="./configure-iphone"
    if [[ ${OPENSSL_PREFIX} ]]; then
        CONFIGURE="${CONFIGURE} --with-ssl=${OPENSSL_PREFIX}"
    fi
    if [[ ${OPENH264_PREFIX} ]]; then
        CONFIGURE="${CONFIGURE} --with-openh264=${OPENH264_PREFIX}"
    fi
    if [[ ${FFMPEG_PREFIX} ]]; then
        CONFIGURE="${CONFIGURE} --with-ffmpeg=${FFMPEG_PREFIX}"
    fi

    # flags
    if [[ ! ${CFLAGS} ]]; then
        export CFLAGS=
    fi
    if [[ ! ${LDFLAGS} ]]; then
        export LDFLAGS=
    fi
    if [[ ${OPENSSL_PREFIX} ]]; then
        export CFLAGS="${CFLAGS} -I${OPENSSL_PREFIX}/include"
        export LDFLAGS="${LDFLAGS} -L${OPENSSL_PREFIX}/lib"
    fi
    if [[ ${OPENH264_PREFIX} ]]; then
        export CFLAGS="${CFLAGS} -I${OPENH264_PREFIX}/include"
        export LDFLAGS="${LDFLAGS} -L${OPENH264_PREFIX}/lib -lopenh264"
    fi
    if [[ ${FFMPEG_PREFIX} ]]; then
        export PKG_CONFIG="none"
        export CFLAGS="${CFLAGS} -I${FFMPEG_PREFIX}/include"
        export LDFLAGS="${LDFLAGS} -L${FFMPEG_PREFIX}/lib -lz -lbz2 -lavcodec -lavformat -lavutil -lswscale"
    fi
    export LDFLAGS="${LDFLAGS} -lstdc++"

    echo "Building for ${ARCH}..."

    make distclean > ${LOG} 2>&1
    ARCH="-arch ${ARCH}" ${CONFIGURE} >> ${LOG} 2>&1
    make dep >> ${LOG} 2>&1
    make clean >> ${LOG}
    make -j$NUMCORES >> ${LOG} 2>&1

    copy_libs ${ARCH}
}

function armv7() {
    export CFLAGS=
    export LDFLAGS=
    _build "armv7"
}
function armv7s() {
    export CFLAGS=
    export LDFLAGS=
    _build "armv7s"
}
function arm64() {
    export CFLAGS=
    export LDFLAGS=
    _build "arm64"
}
function i386() {
    export DEVPATH="`xcrun -sdk iphonesimulator --show-sdk-platform-path`/Developer"
    export CFLAGS="-O2 -m32 -mios-simulator-version-min=7.0"
    export LDFLAGS="-O2 -m32 -mios-simulator-version-min=7.0"
    _build "i386"
}
function x86_64() {
    export DEVPATH="`xcrun -sdk iphonesimulator --show-sdk-platform-path`/Developer"
    export CFLAGS="-O2 -m32 -mios-simulator-version-min=7.0"
    export LDFLAGS="-O2 -m32 -mios-simulator-version-min=7.0"
    _build "x86_64"
}

function lipo() {
    echo "Lipo libs..."

    for LIB in ${LIPO_LIBS[*]}; do
        CMD="xcrun -sdk iphoneos lipo "
        for ARCH in ${LIPO_ARCHS[*]}; do
            INFILE=`echo "${LIB}" | sed "s/ARCH/${ARCH}/"`
            CMD="${CMD} -arch $ARCH ${PJSIP_DIR}/$INFILE-$ARCH-$LIPO_LIB_SUFFIX "
        done
        OUTPUT=`echo "${LIB}" | awk -F "/" '{print $3}'`
        OUTPUT="${OUTPUT}-universal-${LIPO_LIB_SUFFIX}"
        CMD="${CMD} -create -output ${PJSIP_DIR}/lib/${OUTPUT}"
        `${CMD}`
    done
}

download "${PJSIP_URL}" "${PJSIP_DIR}"
config_site "${PJSIP_DIR}"
armv7
armv7s
arm64
i386
x86_64
lipo
