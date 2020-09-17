#!/bin/bash

set -eux

name="atlas"
repo=${1:-${STACK_atlas_repo:-"jcsda"}}
version=${2:-${STACK_atlas_version:-"release-stable"}}

# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')
mpi=$(echo $HPC_MPI | sed 's/\//-/g')

if $MODULES; then
  set +x
  source $MODULESHOME/init/bash
  module load hpc-$HPC_COMPILER
  module load hpc-$HPC_MPI
  module try-load cmake
  module try-load zlib
  module try-load boost-headers
  module try-load eigen
  module load ecbuild
  module load eckit
  module load fckit
  module list
  set -x

  prefix="${PREFIX:-"/opt/modules"}/$compiler/$mpi/$name/$repo-$version"
  if [[ -d $prefix ]]; then
    [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!"; $SUDO rm -rf $prefix ) \
                               || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
  fi
else
  prefix=${ATLAS_ROOT:-"/usr/local"}
fi

export FC=$MPI_FC
export CC=$MPI_CC
export CXX=$MPI_CXX
export FFLAGS="${STACK_FFLAGS:-} ${STACK_atlas_FFLAGS:-} -fPIC"

software=$name-$repo-$version
cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}
[[ -d $software ]] || git clone https://github.com/$repo/$name.git $software
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
git fetch --tags
git checkout $version
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d build ]] && $SUDO rm -rf build
mkdir -p build && cd build

ecbuild --prefix=$prefix --build=Release ..
VERBOSE=$MAKE_VERBOSE make -j${NTHREADS:-4}
[[ $MAKE_CHECK =~ [yYtT] ]] && ctest
VERBOSE=$MAKE_VERBOSE $SUDO make install

# generate modulefile from template
$MODULES && update_modules mpi $name $repo-$version \
         || echo $name $repo-$version >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
