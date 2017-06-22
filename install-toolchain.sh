#!/bin/bash

###############################################################################
#
# Download and build cross-compiler toolchain for Raspberry Pi
#
# Requires: gperf subversion texinfo/makeinfo gawk
#
###############################################################################

# Return with error code on any non-successful operation
set -e

readonly BUILD_DIR=`pwd`

# Crosstool-ng (cross-compiler toolchain builder) information
readonly CROSSTOOL_NG_DL_URL="http://crosstool-ng.org/download/crosstool-ng"
readonly CROSSTOOL_NG_VERSION="1.19.0"
readonly CROSSTOOL_NG_EXTRDIR="crosstool-ng-$CROSSTOOL_NG_VERSION"
readonly CROSSTOOL_NG_INSTALLDIR="$BUILD_DIR/crosstool-ng"
readonly CROSSTOOL_NG_BINDIR="$CROSSTOOL_NG_INSTALLDIR/bin"
readonly CROSSTOOL_NG_FILENAME="$CROSSTOOL_NG_EXTRDIR.tar.bz2"
readonly CROSSTOOL_NG_CONFIG="$BUILD_DIR/resources/pi.config"

readonly TOOLCHAIN_DIR="$BUILD_DIR/toolchain"
readonly LIB_DIR="$BUILD_DIR/lib"
readonly PACKAGES_DIR="$BUILD_DIR/packages"

###############################################################################

do_fetch_toolchain=y
do_config_toolchain=y
do_make_toolchain=y

###############################################################################

msg() {
    echo "[$(date +%Y-%m-%dT%H:%M:%S%z)]: $@" >&2
}

###############################################################################

create_dir_structure() {
  msg "Creating directory structure"
  mkdir $LIB_DIR 
  mkdir $PACKAGES_DIR
}

###############################################################################

fetch_toolchain() {
  msg "Downloading cross-compiler"
  msg "Version: $CROSSTOOL_NG_VERSION"
  local download_link="$CROSSTOOL_NG_DL_URL/$CROSSTOOL_NG_FILENAME"
  wget $download_link
  tar -xjvf $CROSSTOOL_NG_FILENAME
}

###############################################################################

config_toolchain() {
  msg "Configuring crosstool-ng"
  cd $CROSSTOOL_NG_EXTRDIR
  ./configure --prefix=$CROSSTOOL_NG_INSTALLDIR
  make
  make install
  export PATH=$PATH:$CROSSTOOL_NG_BINDIR
}

###############################################################################

make_toolchain() {
  msg "Building toolchain"
  export TOOLCHAIN_DIR # Used to set CT_PREFIX_DIR in pi.config
  cp --verbose $CROSSTOOL_NG_CONFIG $CROSSTOOL_NG_BINDIR/.config
  cd $CROSSTOOL_NG_BINDIR
  ./ct-ng oldconfig
  ./ct-ng build
  cd $BUILD_DIR
}

###############################################################################
# Start execution
###############################################################################

msg "Build directory: $BUILD_DIR"

if [ $do_fetch_toolchain = "y" ]; then
    fetch_toolchain
fi

if [ $do_config_toolchain = "y" ]; then
    config_toolchain
fi

if [ $do_make_toolchain = "y" ]; then
    make_toolchain
fi

exit 0

###############################################################################
# End execution
###############################################################################
