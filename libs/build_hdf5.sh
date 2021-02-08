#!/bin/bash

set -eux

name="hdf5"
version=${1:-${STACK_hdf5_version}}

# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')
mpi=$(echo $HPC_MPI | sed 's/\//-/g')

[[ ${STACK_hdf5_enable_szip:-} =~ [yYtT] ]] && enable_szip=YES || enable_szip=NO
[[ ${STACK_hdf5_enable_zlib:-} =~ [yYtT] ]] && enable_zlib=YES || enable_zlib=NO
[[ ${STACK_hdf5_shared:-} =~ [yYtT] ]] && enable_shared=YES || enable_shared=NO

if $MODULES; then
  set +x
  source $MODULESHOME/init/bash
  module load hpc-$HPC_COMPILER
  [[ -z $HPC_MPI ]] || module load hpc-$HPC_MPI
  [[ $enable_szip =~ [yYtT] ]] && module try-load szip
  [[ $enable_zlib =~ [yYtT] ]] && module try-load zlib
  module list
  set -x

  prefix="${PREFIX:-"/opt/modules"}/$compiler/$mpi/$name/$version"
  if [[ -d $prefix ]]; then
    [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix; $SUDO mkdir $prefix ) \
                               || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
  fi

else
    prefix=${HDF5_ROOT:-"/usr/local"}
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

export F9X=$FC
export FFLAGS="${STACK_FFLAGS:-} ${STACK_hdf5_FFLAGS:-} -fPIC -w"
export CFLAGS="${STACK_CFLAGS:-} ${STACK_hdf5_CFLAGS:-} -fPIC -w"
export CXXFLAGS="${STACK_CXXFLAGS:-} ${STACK_hdf5_CXXFLAGS:-} -fPIC -w"
export FCFLAGS="$FFLAGS"

gitURL="https://github.com/HDFGroup/hdf5.git"

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

software=$name-$(echo $version | sed 's/\./_/g')
[[ -d $software ]] || ( git clone -b $software $gitURL $software )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

[[ -z $mpi ]] || extra_conf="--enable-parallel --enable-unsupported"

[[ $enable_shared =~ [yYtT] ]] || shared_flags="--disable-shared --enable-static --enable-static-exec"
[[ $enable_szip =~ [yYtT] ]] && szip_flags="--with-szlib=$SZIP_ROOT"
[[ $enable_zlib =~ [yYtT] ]] && zlib_flags="--with-zlib=$ZLIB_ROOT"

../configure --prefix=$prefix \
             --enable-fortran --enable-cxx \
             ${szip_flags:-} ${zlib_flags:-} ${shared_flags:-} ${extra_conf:-}

VERBOSE=$MAKE_VERBOSE make -j${NTHREADS:-4}
[[ $MAKE_CHECK =~ [yYtT] ]] && make check
[[ $USE_SUDO =~ [yYtT] ]] && sudo -- bash -c "export PATH=$PATH; make install" \
                          || make install

# generate modulefile from template
[[ -z $mpi ]] && modpath=compiler || modpath=mpi
$MODULES && update_modules $modpath $name $version \
         || echo $name $version >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
