#!/bin/bash

set -eux

name=${1:-${STACK_mpi_flavor}}
version=${2:-${STACK_mpi_version}}

mm=$(echo $version | cut -d. -f-2)
patch=$(echo $version | cut -d. -f3)

case "$name" in
    openmpi ) URL="https://download.open-mpi.org/release/open-mpi/v$mm/openmpi-$version.tar.gz" ;;
    mpich   ) URL="http://www.mpich.org/static/downloads/$version/mpich-$version.tar.gz" ;;
    *       ) echo "Invalid MPI implementation = $name, ABORT!"; exit 1 ;;
esac

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

software=$name-$version
[[ -d $software ]] || ( $WGET $URL; tar -xf $software.tar.gz; rm -f $software.tar.gz )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0

# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')

if $MODULES; then
  set +x
  source $MODULESHOME/init/bash
  module load hpc-$HPC_COMPILER
  module list
  set -x

  prefix="${PREFIX:-"/opt/modules"}/$compiler/$name/$version"
  if [[ -d $prefix ]]; then
      if [[ $OVERWRITE =~ [yYtT] ]]; then
          echo "WARNING: $prefix EXISTS: OVERWRITING!"
          $SUDO rm -rf $prefix
      else
          echo "WARNING: $prefix EXISTS, SKIPPING"
          exit 0
      fi
  fi
else
  prefix=${MPI_ROOT:-"/usr/local"}
fi

export CC=$SERIAL_CC
export CXX=$SERIAL_CXX
export FC=$SERIAL_FC

export FFLAGS="${STACK_FFLAGS:-} ${STACK_mpi_FFLAGS:-} -fPIC"
export CFLAGS="${STACK_CFLAGS:-} ${STACK_mpi_CFLAGS:-} -fPIC"
export CXXFLAGS="${STACK_CXXFLAGS:-} ${STACK_mpi_CXXFLAGS:-} -fPIC"
export FCFLAGS="$FFLAGS"

# Determine if this is GNU Fortran 10+
[[ `$FC --version` =~ GNU\ Fortran.*\ 1[0-9]\.[0-9]+ ]] && FC_GFORTRAN_10=1

[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

# If on a Mac, need to disable -flat_namespace for the link step. This is so because
# we have mixed C/C++ and Fortran in several libraries, and -flat_namespace leads
# to aborts when exceptions are thrown. (See the ZenHub issue JCSDA/oops#649 for details.)
# Fortunately, mpich provides a configure control (--enable-two-level-namespace) for doing
# this. Unfortunately, openmpi has -flat_namepace hardwired into its configure script. A
# workaround for openmpi is to strip off the -flat_namespace settings in the configure
# script using sed.
host=$(uname -s)
case "$name" in
  openmpi )
    extra_conf="--enable-mpi-fortran --enable-mpi-cxx"
    if [[ "$host" == "Darwin" ]]; then
      # On a Mac, use the sed hack to disable -flat_namespace
      sed -i '.bak' -e's/-Wl,-flat_namespace//g' ../configure
      # On a Mac, use Open MPI internal versions of hwloc and libevent
      # see: https://www.open-mpi.org/faq/?category=building#libevent-or-hwloc-errors-when-linking-fortran
      openmpi_conf="--with-hwloc=internal --with-libevent=internal"
      extra_conf+=" $openmpi_conf --with-wrapper-ldflags=-Wl,-commons,use_dylibs"
    fi
    ;;
  mpich )
    extra_conf="--enable-fortran --enable-cxx"
    # On a Mac, use the control to disable -flat_namespace
    [[ "$host" == "Darwin" ]] && extra_conf+=" --enable-two-level-namespace"
    # gfortran-10+ compatibility flags
    if [[ -n ${FC_GFORTRAN_10:-} ]]; then
      # Use these flags to build MPICH itself, but don't add to WRAPPER_FCFLAGS
      export MPICHLIB_FCFLAGS+=" -fallow-argument-mismatch -fallow-invalid-boz"
      export MPICHLIB_FFLAGS=${MPICHLIB_FCFLAGS}
      # Disable check for mismatched args flags in confdb/aclocal_f77.ac
      export pac_cv_prog_f77_mismatched_args=yes
    fi
    [[ -n ${HWLOC_ROOT:-} ]] && extra_conf+=" --with-hwloc-prefix=${HWLOC_ROOT}"
    ;;
  * )
    echo "Invalid option for MPI = $software, ABORT!"
    exit 1
    ;;
esac

../configure --prefix=$prefix $extra_conf
VERBOSE=$MAKE_VERBOSE make -j${NTHREADS:-4}
[[ $MAKE_CHECK =~ [yYtT] ]] && make check
$SUDO make install

# generate modulefile from template
$MODULES && update_modules compiler $name $version
echo $name $version $URL >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
