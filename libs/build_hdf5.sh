#!/bin/bash

set -ex

name="hdf5"
version=${1:-${STACK_hdf5_version}}

# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')
mpi=$(echo $HPC_MPI | sed 's/\//-/g')

if $MODULES; then
  set +x
  source $MODULESHOME/init/bash
  module load hpc-$HPC_COMPILER
  [[ -z $HPC_MPI ]] || module load hpc-$HPC_MPI
  module try-load szip
  module try-load zlib
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
export FFLAGS="-fPIC -w"
export CFLAGS="-fPIC -w"
export CXXFLAGS="-fPIC -w"
export FCFLAGS="$FFLAGS"
SZIP_ROOT=${SZIP_ROOT:-/usr}
ZLIB_ROOT=${ZLIB_ROOT:-/usr}

gitURL="https://bitbucket.hdfgroup.org/scm/hdffv/hdf5.git"

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

software=$name-$(echo $version | sed 's/\./_/g')
[[ -d $software ]] || ( git clone -b $software $gitURL $software )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

[[ -z $mpi ]] || extra_conf="--enable-parallel --enable-unsupported"

[[ ${STACK_hdf5_shared} =~ [yYtT] ]] || shared_flags="--disable-shared --enable-static --enable-static-exec"

../configure --prefix=$prefix \
             --enable-fortran --enable-cxx \
             --with-szlib=$SZIP_ROOT --with-zlib=$ZLIB_ROOT \
             $shared_flags $extra_conf

VERBOSE=$MAKE_VERBOSE make -j${NTHREADS:-4}
[[ $MAKE_CHECK =~ [yYtT] ]] && make check
[[ $USE_SUDO =~ [yYtT] ]] && sudo -- bash -c "export PATH=$PATH; make install" \
                          || make install

# generate modulefile from template
[[ -z $mpi ]] && modpath=compiler || modpath=mpi
$MODULES && update_modules $modpath $name $version \
         || echo $name $version >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
