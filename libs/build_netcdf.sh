#!/bin/bash

set -eux

name="netcdf"
c_version=${1:-${STACK_netcdf_version_c}}
f_version=${2:-${STACK_netcdf_version_f}}
cxx_version=${3:-${STACK_netcdf_version_cxx}}

# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')
mpi=$(echo $HPC_MPI | sed 's/\//-/g')

[[ ${STACK_netcdf_enable_pnetcdf:-} =~ [yYtT] ]] && enable_pnetcdf=YES || enable_pnetcdf=NO
[[ ${STACK_netcdf_disable_cxx:-} =~ [yYtT]  ]] && enable_cxx=NO || enable_cxx=YES

if $MODULES; then
    set +x
    source $MODULESHOME/init/bash
    module load hpc-$HPC_COMPILER
    [[ -z $mpi ]] || module load hpc-$HPC_MPI
    module try-load szip
    module load hdf5
    if [[ ! -z $mpi ]]; then
      [[ $enable_pnetcdf =~ [yYtT] ]] && module load pnetcdf
    fi
    module list
    set -x

    prefix="${PREFIX:-"/opt/modules"}/$compiler/$mpi/$name/$c_version"
    if [[ -d $prefix ]]; then
        [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix; $SUDO mkdir $prefix ) \
                                   || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
    fi

else
    prefix=${NETCDF_ROOT:-"/usr/local"}
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

export F77=$FC
export F9X=$FC
export FFLAGS="${STACK_FFLAGS:-} ${STACK_netcdf_FFLAGS:-} -fPIC"
export CFLAGS="${STACK_CFLAGS:-} ${STACK_netcdf_CFLAGS:-} -fPIC"
export CXXFLAGS="${STACK_CXXFLAGS:-} ${STACK_netcdf_CXXFLAGS:-} -fPIC -std=c++11"
export FCFLAGS="$FFLAGS"

gitURLroot="https://github.com/Unidata"

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}
curr_dir=$(pwd)

LDFLAGS1="-L$HDF5_ROOT/lib"
LDFLAGS2=$(cat $HDF5_ROOT/lib/libhdf5.settings | grep AM_LDFLAGS | cut -d: -f2)
[[ $enable_pnetcdf =~ [yYtT] ]] && LDFLAGS4="-L$PNETCDF_ROOT/lib"
if [[ ${STACK_netcdf_shared:-} != [yYtT] ]]; then
  LDFLAGS1+=" -lhdf5_hl -lhdf5"
  LDFLAGS3=$(cat $HDF5_ROOT/lib/libhdf5.settings | grep "Extra libraries" | cut -d: -f2)
  [[ $enable_pnetcdf =~ [yYtT] ]] && LDFLAGS4+=" -lpnetcdf"
fi
export LDFLAGS="${LDFLAGS1:-} ${LDFLAGS2:-} ${LDFLAGS3:-} ${LDFLAGS4:-}"

export CFLAGS+=" -I$HDF5_ROOT/include"
export CPPFLAGS+=" -I$HDF5_ROOT/include"

cd $curr_dir

##################################################
# Download only

if [[ ${DOWNLOAD_ONLY} =~ [yYtT] ]]; then

    version=$c_version
    software=$name-"c"-$version
    [[ -d $software ]] || ( git clone -b "v$version" $gitURLroot/$name-c.git $software )

    version=$f_version
    software=$name-"fortran"-$version
    [[ -d $software ]] || ( git clone -b "v$version" $gitURLroot/$name-fortran.git $software )

    version=$cxx_version
    software=$name-"cxx4"-$version
    [[ -d $software ]] || ( git clone -b "v$version" $gitURLroot/$name-cxx4.git $software )

    exit 0

fi

##################################################

set +x
echo "################################################################################"
echo "BUILDING NETCDF-C"
echo "################################################################################"
set -x

version=$c_version
software=$name-"c"-$version
[[ -d $software ]] || ( git clone -b "v$version" $gitURLroot/$name-c.git $software )
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

[[ ${STACK_netcdf_shared} =~ [yYtT] ]] || shared_flags="--disable-shared"
[[ $enable_pnetcdf =~ [yYtT] ]] && pnetcdf_conf="--enable-pnetcdf"
[[ -z $mpi ]] || extra_conf="--enable-parallel-tests"

../configure --prefix=$prefix \
             --enable-cdf5 \
             --disable-dap \
             --enable-netcdf-4 \
             --disable-doxygen \
             ${shared_flags:-} ${pnetcdf_conf:-} ${extra_conf:-}

VERBOSE=$MAKE_VERBOSE make -j${NTHREADS:-4}
[[ $MAKE_CHECK =~ [yYtT] ]] && make check
$SUDO make install

$MODULES || echo $software >> ${HPC_STACK_ROOT}/hpc-stack-contents.log

##################################################

# generate modulefile from template
[[ -z $mpi ]] && modpath=compiler || modpath=mpi
$MODULES && update_modules $modpath $name $c_version \
         || echo $software >> ${HPC_STACK_ROOT}/hpc-stack-contents.log

##################################################

set +x
echo "################################################################################"
echo "BUILDING NETCDF-Fortran"
echo "################################################################################"
set -x

# Load netcdf-c before building netcdf-fortran
set +x
$MODULES && module load netcdf
$MODULES && module list
set -x

if [[ ${STACK_netcdf_shared} =~ [yYtT] ]]; then
  export LIBS=$($prefix/bin/nc-config --libs)
  export LDFLAGS+=" -L$prefix/lib"
else
  export LIBS=$($prefix/bin/nc-config --libs --static)
  export LDFLAGS+=" -L$prefix/lib -lnetcdf"
fi
export CFLAGS+=" -I$prefix/include"
export CXXFLAGS+=" -I$prefix/include"

cd $curr_dir

version=$f_version
software=$name-"fortran"-$version
[[ -d $software ]] || ( git clone -b "v$version" $gitURLroot/$name-fortran.git $software )
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

../configure --prefix=$prefix \
             ${shared_flags:-}

#VERBOSE=$MAKE_VERBOSE make -j${NTHREADS:-4}
VERBOSE=$MAKE_VERBOSE make -j1 #NetCDF-Fortran-4.5.2 & intel/20 have a linker bug if built with j>1
[[ $MAKE_CHECK =~ [yYtT] ]] && make check
$SUDO make install

$MODULES || echo $software >> ${HPC_STACK_ROOT}/hpc-stack-contents.log

if [ $enable_cxx =~ [yYtT] ]; then 
   
  cd $curr_dir

  set +x
  echo "################################################################################"
  echo "BUILDING NETCDF-CXX"
  echo "################################################################################"
  set -x

  version=$cxx_version
  software=$name-"cxx4"-$version
  [[ -d $software ]] || ( git clone -b "v$version" $gitURLroot/$name-cxx4.git $software )
  [[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
  [[ -d build ]] && rm -rf build
  mkdir -p build && cd build

  ../configure --prefix=$prefix \
               ${shared_flags:-}

  VERBOSE=$MAKE_VERBOSE make -j${NTHREADS:-4}
  [[ $MAKE_CHECK =~ [yYtT] ]] && make check
  $SUDO make install

  $MODULES || echo $software >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
fi
