#!/bin/bash

#
# CGAL Library used by Atlas
# https://www.cgal.org
#
# WARNING:
#   Dependencies include the gnu gmp and mpfr libraries
#   Also, if you are using gnu compilers prior to 9.0, then
#   you also need to install the boost.thread libraries.
#   These are often availble from package managers such as
#   apt, yum, or brew.  For example, for debian systems:
#
#   sudo apt-get update
#   sudo apt-get install libgmp-dev
#   sudo apt-get install libmpfr-dev
#   sudo apt-get install libboost-thread-dev
#
#

set -eux

name="cgal"
version=${1:-${STACK_cgal_version}}

if $MODULES; then
  set +x
  source $MODULESHOME/init/bash
  module load hpc-$HPC_COMPILER
  module load zlib
  module load boost-headers
  module list
  set -x

  prefix="${PREFIX:-"/opt/modules"}/core/$name/$version"
  if [[ -d $prefix ]]; then
    [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!"; $SUDO rm -rf $prefix ) \
                               || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
  fi
else
  prefix=${CGAL_ROOT:-"/usr/local"}
fi

cd $HPC_STACK_ROOT/${PKGDIR:-"pkg"}

software="CGAL-"$version
url="https://github.com/CGAL/cgal/releases/download/releases%2FCGAL-$version/$software-library.tar.xz"
[[ -d $software ]] || ( $WGET $url; tar -xf $software-library.tar.xz )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )

cmake . -DCMAKE_INSTALL_PREFIX=$prefix
$SUDO make install

# generate modulefile from template
$MODULES && update_modules core $name $version \
         || echo $name $version >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
