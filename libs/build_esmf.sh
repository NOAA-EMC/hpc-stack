#!/bin/bash

set -ex

name="esmf"
version=$1

software=${name}_$version

# Hyphenated versions used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')
mpi=$(echo $HPC_MPI | sed 's/\//-/g')

if $MODULES; then
  set +x
  source $MODULESHOME/init/bash
  module load hpc-$HPC_COMPILER
  module try-load szip
  [[ -z $mpi ]] || module load hpc-$HPC_MPI 
  module load hdf5
  [[ -z $mpi ]] || module load pnetcdf
  module load netcdf
  module try-load udunits
  module list
  set -x

  prefix="${PREFIX:-"/opt/modules"}/$compiler/$mpi/$name/$version"
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
export FFLAGS="-fPIC"
export CFLAGS="-fPIC"
export CXXFLAGS="-fPIC"
export FCFLAGS="$FFLAGS"

if [[ ! -z $mpi ]]; then
  if [[ $(echo $mpi | cut -d- -f1) = "openmpi" ]]; then
    export ESMF_COMM="openmpi"
  elif [[ $(echo $mpi | cut -d- -f1) = "mpich" ]]; then
    export ESMF_COMM="mpich3"
  elif [[ $(echo $mpi | cut -d- -f1) = "impi" ]]; then
    export ESMF_COMM="intelmpi"
  fi
else
  export ESMF_COMM="mpiuni"
fi

export ESMF_COMPILER=$(echo $compiler | cut -d- -f1)

if [[ $ESMF_COMPILER = "intel" ]]; then
  export ESMF_F90COMPILEOPTS="-g -traceback -fp-model precise"
  export ESMF_CXXCOMPILEOPTS="-g -traceback -fp-model precise"
elif [[ $ESMF_COMPILER = "gnu" ]]; then
  export ESMF_COMPILER="gfortran"
fi

export ESMF_CXXCOMPILER=$CXX
export ESMF_CXXLINKER=$CXX
export ESMF_F90COMPILER=$FC
export ESMF_F90LINKER=$FC
export ESMF_NETCDF=nc-config
[[ -z $mpi ]] || export ESMF_PNETCDF=pnetcdf-config
export ESMF_BOPT=O
export ESMF_OPTLEVEL=2
export ESMF_INSTALL_PREFIX=$prefix
export ESMF_INSTALL_BINDIR=bin
export ESMF_INSTALL_LIBDIR=lib
export ESMF_INSTALL_MODDIR=mod
export ESMF_ABI=64

gitURL="https://git.code.sf.net/p/esmf/esmf.git"

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

software="ESMF_$version"
[[ -d $software ]] || ( git clone -b $software $gitURL $software )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
export ESMF_DIR=$PWD

make -j${NTHREADS:-4}
$SUDO make install
[[ $MAKE_CHECK =~ [yYtT] ]] && make installcheck

# generate modulefile from template
[[ -z $mpi ]] && modpath=compiler || modpath=mpi
$MODULES && update_modules $modpath $name $version \
         || echo $name $version >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
