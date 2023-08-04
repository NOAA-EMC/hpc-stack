#!/bin/bash

set -eux

name="fms"
repo=${1:-${STACK_fms_repo:-"noaa-gfdl"}}
version=${2:-${STACK_fms_version:-"master"}}

# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')
mpi=$(echo $HPC_MPI | sed 's/\//-/g')

if $MODULES; then
  set +x
  source $MODULESHOME/init/bash
  module load hpc-$HPC_COMPILER
  module load hpc-$HPC_MPI
  module try-load cmake
  module load netcdf
  module list
  set -x

  prefix="${PREFIX:-"/opt/modules"}/$compiler/$mpi/$name/$version"
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
  prefix=${FMS_ROOT:-"/usr/local"}
fi

export FC=$MPI_FC
export CC=$MPI_CC

export CFLAGS="${STACK_CFLAGS:-} ${STACK_fms_CFLAGS:-} -fPIC -w"
export FFLAGS="${STACK_FFLAGS:-} ${STACK_fms_FFLAGS:-} -fPIC -w"
export FCFLAGS="${FFLAGS}"

software=$name-$repo-$version
cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}
URL="https://github.com/$repo/$name.git"
[[ -d $software ]] || git clone $URL $software
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )

git checkout $version
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0

# Patch if requested
if [[ ! -z "${STACK_fms_PATCH+x}" ]]; then
  patch -p0 < ${HPC_STACK_ROOT}/patches/${STACK_fms_PATCH}
fi

[[ -d build ]] && $SUDO rm -rf build
mkdir -p build && cd build

CMAKE_OPTS=${STACK_fms_cmake_opts:-""}

cmake .. -DCMAKE_INSTALL_PREFIX=$prefix ${CMAKE_OPTS}

VERBOSE=$MAKE_VERBOSE make -j${NTHREADS:-4}
#[[ $MAKE_CHECK =~ [yYtT] ]] && make check # make check is not implemented in cmake builds
VERBOSE=$MAKE_VERBOSE $SUDO make install

# generate modulefile from template
$MODULES && update_modules mpi $name $version
echo $name $version $URL >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
