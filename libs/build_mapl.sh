#!/bin/bash

set -eux

name="mapl"
repo="GEOS-ESM"
version=${2:-${STACK_mapl_version:-"main"}}

# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')
mpi=$(echo $HPC_MPI | sed 's/\//-/g')
id=${version//\//-}

if $MODULES; then
  set +x
  source $MODULESHOME/init/bash
  module load hpc-$HPC_COMPILER
  module load hpc-$HPC_MPI
  module try-load cmake
  module load esma_cmake
  module load cmakemodules
  module load ecbuild
  # module exports ecbuild_ROOT, but when building without modules ECBUILD_ROOT is set
  export ECBUILD_ROOT=$ecbuild_ROOT
  module load gftl-shared
  module load yafyaml
  module load netcdf
  module load esmf
  module list

  set -x

  prefix="${PREFIX:-"/opt/modules"}/$compiler/$mpi/$name/$id"
  if [[ -d $prefix ]]; then
    [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!"; $SUDO rm -rf $prefix; $SUDO mkdir $prefix ) \
                               || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
  fi
else
  prefix=${MAPL_ROOT:-"/usr/local"}
  export ESMFMKFILE=$ESMF_ROOT/lib/esmf.mk
fi

export FC=$MPI_FC
export CC=$MPI_CC
export CXX=$MPI_CXX

software=$name-$id
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
      -DCMAKE_MODULE_PATH="${ESMA_CMAKE_ROOT};${CMAKEMODULES_ROOT}/Modules;${ECBUILD_ROOT}/share/ecbuild/cmake" \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_WITH_FLAP=OFF \
      -DBUILD_WITH_PFLOGGER=OFF \
      -DESMA_USE_GFE_NAMESPACE=ON \
      -DBUILD_SHARED_MAPL=OFF \
      ${CMAKE_OPTS}

VERBOSE=$MAKE_VERBOSE make -j${NTHREADS:-4} install

# generate modulefile from template
modpath=mpi
$MODULES && update_modules $modpath $name $id
echo $name $id $URL >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
