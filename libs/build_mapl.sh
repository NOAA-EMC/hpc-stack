#!/bin/bash

set -eux

name="mapl"
repo="GEOS-ESM"
version=${2:-${STACK_mapl_version:-"main"}}

# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')
mpi=$(echo $HPC_MPI | sed 's/\//-/g')
id=$(echo $version | sed 's/v//')

if $MODULES; then
  set +x
  source $MODULESHOME/init/bash
  module load hpc-$HPC_COMPILER
  module load hpc-$HPC_MPI
  module load PrgEnv-intel/8.1.0
  module load intel/19.1.3.304
  module load craype/2.7.10
  module load cray-mpich/8.1.9
  module try-load cmake
  module load esma_cmake
  module load cmakemodules
  module load ecbuild
  # module exports ecbuild_ROOT, but when building without modules ECBUILD_ROOT is set
  #export ECBUILD_ROOT=$ecbuild_ROOT
  module load gftl_shared
  module load yafyaml
  module load netcdf/4.9.1
  module load esmf/${STACK_mapl_esmf_version:-default}
  module list

  set -x

  short_esmf_ver=$(echo ${ESMF_VERSION:-} | sed "s:beta_snapshot:bs:")
  install_as=${STACK_mapl_install_as:-"${id}-esmf-${short_esmf_ver}"}
  prefix="${PREFIX:-"/opt/modules"}/$compiler/$mpi/$name/$install_as"
  if [[ -d $prefix ]]; then
      if [[ $OVERWRITE =~ [yYtT] ]]; then
          echo "WARNING: $prefix EXISTS: OVERWRITING!"
          $SUDO rm -rf $prefix
          $SUDO mkdir $prefix
      else
          echo "WARNING: $prefix EXISTS, SKIPPING"
          exit 0
      fi
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

git checkout $version
# sanitize package as per NCO request
# Issue (1)
sed -i 's/http:\/\/gmao.gsfc.nasa.gov/DISABLED_BY_DEFAULT/g' gridcomps/History/MAPL_HistoryGridComp.F90
# Issue (2)
sed -i 's/http:\/\/gmao.gsfc.nasa.gov/DISABLED_BY_DEFAULT/g' base/MAPL_CFIO.F90
# Issue (3)
[[ ! -f base/mapl_tree.py ]] || ( rm base/mapl_tree.py )

# Verify that the changes were applied
git --no-pager diff

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
      -DUSE_EXTDATA2G=OFF \
      -DBUILD_WITH_FARGPARSE=NO \
      ${CMAKE_OPTS}

VERBOSE=$MAKE_VERBOSE make -j${NTHREADS:-4} install

# generate modulefile from template
modpath=mpi

module_substitutions="-DMAPL_ESMF_VERSION=${ESMF_VERSION:-}"
$MODULES && update_modules $modpath $name $install_as "" $module_substitutions
echo $name $id $URL >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
