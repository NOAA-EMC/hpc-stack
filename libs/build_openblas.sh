#!/bin/bash

set -eux

name="openblas"
version=${1:-${STACK_openblas_version}}

# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')

if $MODULES; then
  set +x
  source $MODULESHOME/init/bash
  module is-loaded netcdf && module unload netcdf
  module is-loaded intel &&  module unload intel
  module load hpc-$HPC_COMPILER
  module list
  set -x

  prefix="${PREFIX:-"/opt/modules"}/$compiler/$name/$version"
  if [[ -d $prefix ]]; then
      if [[ $OVERWRITE =~ [yYtT] ]]; then
          echo "WARNING: $prefix EXISTS: OVERWRITING!"
          $SUDO rm -rf $prefix
      else
          echo "WARNING: $prefix EXISTS, SKIPPING"
          exit 0
      fi
  fi
else
  prefix=${OPENBLAS_ROOT:-"/usr/local"}
fi

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

software="OpenBLAS-$version"
URL="https://github.com/xianyi/OpenBLAS/releases/download/v$version/$software.tar.gz"
[[ -f $software.tar.gz ]] || ( $WGET $URL )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0

[[ -f $software.tar.gz ]] && tar -xvf $software.tar.gz || ( echo "$software tarfile does not exist, ABORT!"; exit 1 )
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )

FC=${FC:-gfortran}

make FC=$FC -j${NTHREADS:-4}

make PREFIX=$prefix install

# generate modulefile from template
modpath=compiler
$MODULES && update_modules $modpath $name $version
echo $name $version $URL >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
