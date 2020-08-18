#!/bin/bash

set -eux

name="esmf"
version=${1:-${STACK_esmf_version}}

software=${name}_$version

# Hyphenated versions used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')
mpi=$(echo $HPC_MPI | sed 's/\//-/g')

COMPILER=$(echo $compiler | cut -d- -f1)
MPI=$(echo $mpi | cut -d- -f1)

[[ $STACK_esmf_enable_pnetcdf =~ [yYtT] ]] && enable_pnetcdf=YES || enable_pnetcdf=NO
[[ ${STACK_esmf_shared} =~ [yYtT] ]] && enable_shared=YES || enable_shared=NO

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
export FFLAGS="${STACK_esmf_FFLAGS:-} -fPIC"
export CFLAGS="${STACK_esmf_CFLAGS:-} -fPIC"
export CXXFLAGS="${STACK_esmf_CXXFLAGS:-} -fPIC"
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

#  mpiexec --version | grep OpenRTE 2> /dev/null && export ESMF_COMM=openmpi
#  mpiexec --version | grep Intel   2> /dev/null && export ESMF_COMM=intelmpi
export ESMF_MPIRUN=mpiexec
case $MPI in
  openmpi )
    export ESMF_COMM="openmpi"
    ;;
  mpich )
    export ESMF_COMM="mpich3"
    ;;
  impi )
    export ESMF_COMM="intelmpi"
    ;;
  * )
    export ESMF_COMM="mpiuni"
    export ESMF_MPIRUN=""
    ;;
esac

case $COMPILER in
  intel|ips )
    export ESMF_COMPILER="intel"
    export ESMF_F90COMPILEOPTS="-g -traceback -fp-model precise"
    export ESMF_CXXCOMPILEOPTS="-g -traceback -fp-model precise"
    ;;
  gnu|gcc )
    export ESMF_COMPILER="gfortran"
    ;;
  * )
    echo "Unsupported compiler = $COMPILER, ABORT!"; exit 1
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
export ESMF_BOPT=O
#export ESMF_OPTLEVEL=2
export ESMF_ABI=64

export ESMF_INSTALL_PREFIX=$prefix
export ESMF_INSTALL_BINDIR=bin
export ESMF_INSTALL_LIBDIR=lib
export ESMF_INSTALL_MODDIR=mod
export ESMF_INSTALL_HEADERDIR=include
[[ $enable_shared =~ [yYtT] ]] || export ESMF_SHARED_LIB_BUILD=OFF

make info
make -j${NTHREADS:-4}
$SUDO make install
[[ $MAKE_CHECK =~ [yYtT] ]] && make installcheck

# generate modulefile from template
[[ -z $mpi ]] && modpath=compiler || modpath=mpi
$MODULES && update_modules $modpath $name $version \
         || echo $name $version >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
