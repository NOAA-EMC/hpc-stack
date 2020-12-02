#!/bin/bash

set -eux

name="esmf"
version=${1:-${STACK_esmf_version}}

software=${name}_$version

# Hyphenated versions used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')
mpi=$(echo $HPC_MPI | sed 's/\//-/g')

COMPILER=$(echo $HPC_COMPILER | cut -d/ -f1)
MPI=$(echo $HPC_MPI | cut -d/ -f1)

host=$(uname -s)

[[ $STACK_esmf_enable_pnetcdf =~ [yYtT] ]] && enable_pnetcdf=YES || enable_pnetcdf=NO
[[ ${STACK_esmf_shared} =~ [yYtT] ]] && enable_shared=YES || enable_shared=NO
[[ ${STACK_esmf_debug} =~ [yYtT] ]] && enable_debug=YES || enable_debug=NO

# This will allow debug version of software (ESMF) to be installed next to the optimized version (this is only affected for $MODULES)
[[ $enable_debug =~ [yYtT] ]] && version_install=$version-debug || version_install=$version

if $MODULES; then
  set +x
  source $MODULESHOME/init/bash
  module load hpc-$HPC_COMPILER
  module try-load zlib
  module try-load szip
  [[ -z $mpi ]] || module load hpc-$HPC_MPI
  module load hdf5
  if [[ ! -z $mpi ]]; then
    [[ $enable_pnetcdf =~ [yYtT] ]] && module load pnetcdf
  fi
  module load netcdf
  module try-load udunits
  module list
  set -x

  prefix="${PREFIX:-"/opt/modules"}/$compiler/$mpi/$name/$version_install"
  if [[ -d $prefix ]]; then
    [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix ) \
                               || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
  fi

else
  prefix=${ESMF_ROOT:-"/usr/local"}
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
export FFLAGS="${STACK_FFLAGS:-} ${STACK_esmf_FFLAGS:-} -fPIC"
export CFLAGS="${STACK_CFLAGS:-} ${STACK_esmf_CFLAGS:-} -fPIC"
export CXXFLAGS="${STACK_CXXFLAGS:-} ${STACK_esmf_CXXFLAGS:-} -fPIC"
export FCFLAGS="$FFLAGS"

gitURL="https://github.com/esmf-org/esmf"

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

software="ESMF_$version"
# ESMF does not support out of source builds; clean out the clone
[[ -d $software ]] && ( echo "$software exists, cleaning ..."; rm -rf $software )
[[ -d $software ]] || ( git clone -b $software $gitURL $software )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
export ESMF_DIR=$PWD

# This is going to need a little work to adapt for various combinations
# of Darwin/Linux with GNU/Clang/Intel etc.
case $COMPILER in
  intel|ips )
    export ESMF_COMPILER="intel"
    export ESMF_F90COMPILEOPTS="-g -traceback -fp-model precise"
    export ESMF_CXXCOMPILEOPTS="-g -traceback -fp-model precise"
    ;;
  gnu|gcc|clang )
    export ESMF_COMPILER="gfortran"
    export ESMF_F90COMPILEOPTS="-g -fbacktrace"
    if [[ "$host" == "Darwin" ]]; then
      export ESMF_CXXCOMPILEOPTS="-g -Wno-error=format-security"
    else
      export ESMF_CXXCOMPILEOPTS="-g"
    fi
    ;;
  #clang )
  #  export ESMF_COMPILER="gfortranclang"
  #  ;;
  * )
    echo "Unsupported compiler = $COMPILER, ABORT!"; exit 1
    ;;
esac

case $MPI in
  openmpi )
    export ESMF_COMM="openmpi"
    ;;
  mpich )
    export ESMF_COMM=${STACK_esmf_comm:-"mpich3"}
    ;;
  cray-mpich )
    export ESMF_COMM=${STACK_esmf_comm:-"mpi"}
    ;;
  impi )
    export ESMF_COMM="intelmpi"
    ;;
  mpt )
    export ESMF_COMM="mpt"
    ;;
  * )
    export ESMF_COMM="mpiuni"
    ;;
esac

HDF5ExtraLibs=$(cat $HDF5_ROOT/lib/libhdf5.settings | grep "Extra libraries" | cut -d: -f2)
HDF5LDFLAGS=$(cat $HDF5_ROOT/lib/libhdf5.settings | grep "AM_LDFLAGS" | cut -d: -f2)

export ESMF_CXXCOMPILER=$CXX
export ESMF_CXXLINKER=$CXX
export ESMF_CXXLINKPATHS="-L$HDF5_ROOT/lib $HDF5LDFLAGS"
export ESMF_F90COMPILER=$FC
export ESMF_F90LINKER=$FC
export ESMF_F90LINKPATHS="-L$HDF5_ROOT/lib $HDF5LDFLAGS"

export ESMF_NETCDF=split
export ESMF_NETCDF_INCLUDE=$NETCDF_ROOT/include
export ESMF_NETCDF_LIBPATH=$NETCDF_ROOT/lib
export ESMF_NETCDF_LIBS="-lnetcdff -lnetcdf -lhdf5_hl -lhdf5 $HDF5ExtraLibs"
export ESMF_NFCONFIG=nf-config
[[ $enable_pnetcdf =~ [yYtT] ]] && export ESMF_PNETCDF=pnetcdf-config
# Configure optimization level
if [[ $enable_debug =~ [yYtT] ]]; then
  export ESMF_BOPT=g
  export ESMF_OPTLEVEL="0"
else
  if [[ "$host" == "Darwin" ]]; then
    export ESMF_BOPT=O
    export ESMF_OPTLEVEL="0"
  else
    export ESMF_BOPT=O
    export ESMF_OPTLEVEL="2"
  fi
fi

export ESMF_INSTALL_PREFIX=$prefix
export ESMF_INSTALL_BINDIR=bin
export ESMF_INSTALL_LIBDIR=lib
export ESMF_INSTALL_MODDIR=mod
export ESMF_INSTALL_HEADERDIR=include
[[ $enable_shared =~ [yYtT] ]] || export ESMF_SHARED_LIB_BUILD=OFF

make info
make -j${NTHREADS:-4}
$SUDO make install
[[ $MAKE_CHECK =~ [yYtT] ]] && make check
[[ $MAKE_CHECK =~ [yYtT] ]] && make installcheck

# generate modulefile from template
[[ -z $mpi ]] && modpath=compiler || modpath=mpi
$MODULES && update_modules $modpath $name $version_install \
         || echo $name $version >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
