#!/bin/bash

set -eux

name="mapl"
repo=${1:-${STACK_mapl_repo:-"GEOS-ESM"}}
version=${2:-${STACK_mapl_version:-"main"}}

# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')
mpi=$(echo $HPC_MPI | sed 's/\//-/g')
id=${version//\//-}
version_install=$repo-$id

if $MODULES; then
  set +x
  source $MODULESHOME/init/bash
  module load hpc-$HPC_COMPILER
  module load hpc-$HPC_MPI
  module load hpc-$HPC_PYTHON
  module try-load cmake
  module load esma_cmake
  module load cmakemodules
  module load ecbuild
  module load gftl-shared
  module load yafyaml
  module load esmf
  module load netcdf
  module list

  set -x

  prefix="${PREFIX:-"/opt/modules"}/$compiler/$mpi/$name/$version_install"
  if [[ -d $prefix ]]; then
    [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!"; $SUDO rm -rf $prefix; $SUDO mkdir $prefix ) \
                               || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
  fi
else
  prefix=${CMAKEMODULES_ROOT:-"/usr/local"}
fi

if [[ ! -z $mpi ]]; then
  export FC=$MPI_FC
  export CC=$MPI_CC
  export CXX=$MPI_CXX
else
  export FC=$SERIAL_FC
  export CC=$SERIAL_CC
  export CXX=$SERIAL_CXX
fi

software=$name-$version_install
cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}
URL="https://github.com/$repo/$name.git"
[[ -d $software ]] || git clone $URL $software
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )

git fetch --tags
git checkout $version
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0

[[ -d build ]] && $SUDO rm -rf build
mkdir -p build && cd build

CMAKE_OPTS=${STACK_mapl_cmake_opts:-""}

cmake .. \
      -DCMAKE_INSTALL_PREFIX=$prefix \
      -DCMAKE_MODULE_PATH=$CMAKE_MODULE_PATH \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_WITH_FLAP=OFF \
      -DBUILD_WITH_PFLOGGER=OFF \
      -DESMA_USE_GFE_NAMESPACE=ON \
      -DBUILD_SHARED_MAPL=OFF \
      ${CMAKE_OPTS}

VERBOSE=$MAKE_VERBOSE make -j${NTHREADS:-4} install

# generate modulefile from template
[[ -z $mpi ]] && modpath=compiler || modpath=mpi
$MODULES && update_modules $modpath $name $version_install
echo $name $version_install $URL >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
