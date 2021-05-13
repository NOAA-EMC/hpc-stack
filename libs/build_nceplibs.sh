#!/bin/bash

set -eux

name=$1

var_version="STACK_${name}_version"
var_install_as="STACK_${name}_install_as"
var_openmp="STACK_${name}_openmp"

set +u
s_version=${!var_version}
s_install_as=${!var_install_as}
s_openmp=${!var_openmp}
set -u

version=${2:-$s_version}    # second column of COMPONENTS
install_as=${3:-${s_install_as}} #  third column of COMPONENTS
openmp=${4:-${s_openmp:-"OFF"}}

# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')
mpi=$(echo $HPC_MPI | sed 's/\//-/g')
python=$(echo $HPC_PYTHON | sed 's/\//-/g')

if $MODULES; then
  set +x
  source $MODULESHOME/init/bash
  module load hpc-$HPC_COMPILER

  case $name in
    # The following require MPI
    nemsio | nemsiogfs | ncio | nceppost | upp | w3emc)
      module load hpc-$HPC_MPI
      using_mpi=YES
      ;;
    # The following can use MPI (if available)
    wrf_io | gsiwrfio | wgrib2)
      if [[ ! -z $mpi ]]; then
        module load hpc-$HPC_MPI
        using_mpi=YES
      fi
      ;;
  esac

  # Load dependencies
  case $name in
    wrf_io | gsiwrfio )
      module load netcdf
      ;;
    wgrib2)
      module try-load jpeg
      module try-load jasper
      module try-load zlib
      module try-load png
      module load netcdf
      module load sp
      module load ip2
      ;;
    ip2)
      module load sp
      ;;
    g2)
      module try-load jpeg
      module try-load png
      module try-load jasper
      ;;
    g2c)
      module try-load jpeg
      module try-load png
      module try-load jasper
      ;;
    nemsio)
      module load bacio
      module load w3nco
      ;;
    nemsiogfs)
      module load nemsio
      ;;
    w3emc)
      module load netcdf
      module load sigio
      module load nemsio
      ;;
    nceppost | upp)
      module try-load png
      module try-load jasper
      module load netcdf
      module load bacio
      module load w3nco
      module load g2
      module load g2tmpl
      module load ip
      module load sp
      module load w3emc
      module load crtm
      # post executable requires the following,
      # but we are not building post executable
      # module load sigio
      # module load sfcio
      # module load gfsio
      # module load nemsio
      ;;
    grib_util)
      module try-load jpeg
      module try-load jasper
      module try-load zlib
      module try-load png
      module load bacio
      module load w3nco
      module load g2
      module load ip
      module load sp
      ;;
    prod_util)
      module load w3nco
      ;;
    ncio)
      module load netcdf
      ;;
    bufr)
      if [[ ! -z $python ]]; then
        if [[ ${STACK_bufr_python:-} =~ [yYtT] ]]; then
          module load hpc-$HPC_PYTHON
          using_python=YES
        fi
      fi
      ;;
  esac
  module list
  set -x

  if [[ ${using_mpi:-} =~ [yYtT] ]]; then
    prefix="${PREFIX:-"/opt/modules"}/$compiler/$mpi/$name/$install_as"
  else
    prefix="${PREFIX:-"/opt/modules"}/$compiler/$name/$install_as"
  fi
  if [[ -d $prefix ]]; then
    [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix; $SUDO mkdir $prefix ) \
                               || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
  fi

else

  nameUpper=$(echo $name | tr [a-z] [A-Z])
  eval prefix="\${${nameUpper}_ROOT:-'/usr/local'}"
  case $name in
    # The following require MPI
    nemsio | nemsiogfs | ncio | nceppost | upp | w3emc)
      using_mpi=YES
      ;;
    # The following can use MPI (if available)
    wrf_io | gsiwrfio | wgrib2)
      [[ ! -z $mpi ]] && using_mpi=YES
      ;;
  esac

fi

if [[ ${using_mpi:-} =~ [yYtT] ]]; then
  export FC=$MPI_FC
  export CC=$MPI_CC
  export CXX=$MPI_CXX
else
  export FC=$SERIAL_FC
  export CC=$SERIAL_CC
  export CXX=$SERIAL_CXX
fi

eval fflags="\${STACK_${name}_FFLAGS:-}"
eval cflags="\${STACK_${name}_CFLAGS:-}"
eval cxxflags="\${STACK_${name}_CXXFLAGS:-}"

export F9X=$FC
export FFLAGS="${STACK_FFLAGS:-} $fflags -fPIC -w"
export CFLAGS="${STACK_CFLAGS:-} $cflags -fPIC -w"
export CXXFLAGS="${STACK_CXXFLAGS:-} $cxxflags -fPIC -w"
export FCFLAGS="$FFLAGS"

# Set properties based on library name
URL="https://github.com/noaa-emc/nceplibs-$name"
extraCMakeFlags=""
case $name in
  nceppost | upp)
    URL="https://github.com/noaa-emc/emc_post"
    extraCMakeFlags="-DBUILD_POSTEXEC=OFF"
    ;;
  crtm)
    URL="https://github.com/noaa-emc/emc_crtm"
    ;;
  gsiwrfio)
    URL="https://github.com/comgsi/gsiwrfio"
    ;;
  wgrib2)
    [[ -z ${STACK_wgrib2_ipolates:-} ]] && ipolates=0   || ipolates=$STACK_wgrib2_ipolates
    [[ -z ${STACK_wgrib2_spectral:-} ]] && spectral=OFF || spectral=$STACK_wgrib2_spectral
    extraCMakeFlags="-DUSE_SPECTRAL=$spectral -DUSE_IPOLATES=$ipolates"
    ;;
  bufr)
    if [[ ${using_python:-} =~ [yYtT] ]]; then
      extraCMakeFlags="-DENABLE_PYTHON=ON"
    fi
    ;;
esac

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

software=$name-$version
#[[ -d $software ]] || ( git clone --recursive -b $version $URL $software )
if [[ ! -d $software ]]; then
  git clone $URL $software
  cd $software
  git checkout $version
  git submodule update --init --recursive
  cd ..
fi
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

cmake .. \
  -DCMAKE_INSTALL_PREFIX=$prefix \
  -DENABLE_TESTS=OFF -DOPENMP=${openmp} ${extraCMakeFlags:-}

VERBOSE=$MAKE_VERBOSE make -j${NTHREADS:-4}
[[ $MAKE_CHECK =~ [yYtT] ]] && make check
[[ $USE_SUDO =~ [yYtT] ]] && sudo -- bash -c "export PATH=$PATH; make install" \
                          || make install

# generate modulefile from template
[[ ${using_mpi:-} =~ [yYtT] ]] && modpath=mpi || modpath=compiler
[[ ${using_python:-} =~ [yYtT] ]] && py_version="$(python3 --version | cut -d " " -f2 | cut -d. -f1-2)"
$MODULES && update_modules $modpath $name $install_as ${py_version:-}
echo $name $version $URL >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
