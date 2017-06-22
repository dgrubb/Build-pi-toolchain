#!/bin/bash

###############################################################################
#
# Download and build cross-compiler toolchain for Raspberry Pi
#
###############################################################################

# Return with error code on any non-successful operation
set -e

###############################################################################

err() {
    echo "[$(date + '%Y-%m-%dT%H:%s%z')]: $@" >&2
}

###############################################################################

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
# Creates directory structure for build staging

create_dir_structure() {
  echo "Creating directory structure"
  mkdir $LIB_DIR 
  mkdir $PACKAGES_DIR
}

###############################################################################

# Download crosstool-ng
fetch_toolchain() {
  echo "Downloading cross-compiler"
  echo "Version: $CROSSTOOL_NG_VERSION"
  local download_link="$CROSSTOOL_NG_DL_URL/$CROSSTOOL_NG_FILENAME"
  wget $download_link
}

# Configure the crosstool-ng make
config_toolchain() {
  echo "Configuring crosstool-ng"
# Requires: gperf subversion texinfo/makeinfo gawk
  cd $CROSSTOOL_NG_EXTRDIR
  ./configure --prefix=$CROSSTOOL_NG_INSTALLDIR
  make
  make install
  export PATH=$PATH:$CROSSTOOL_NG_BINDIR
}

# build toolchain binaries
make_toolchain() {
  echo "Building toolchain"
  export TOOLCHAIN_DIR # Used to set CT_PREFIX_DIR in pi.config
  cp --verbose $CROSSTOOL_NG_CONFIG $CROSSTOOL_NG_BINDIR/.config
  cd $CROSSTOOL_NG_BINDIR
  ./ct-ng oldconfig
  ./ct-ng build
  cd $BUILD_DIR
}

#
# START EXECUTION
#
echo "Build directory: $BUILD_DIR"
fetch_toolchain
tar -xjvf $CROSSTOOL_NG_FILENAME
config_toolchain
make_toolchain

# Finished
exit 0
