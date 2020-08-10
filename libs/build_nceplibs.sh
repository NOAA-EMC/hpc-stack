#!/bin/bash

set -ex

name=$1       #  first column of COMPONENTS
version=$2    # second column of COMPONENTS
install_as=$3 #  third column of COMPONENTS
OPENMP=${4:-"OFF"}

# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')
mpi_check=$(echo $HPC_MPI | sed 's/\//-/g')

if $MODULES; then
  set +x
  source $MODULESHOME/init/bash
  module load hpc-$HPC_COMPILER

  # Load dependencies
  case $name in
    wrf_io)
      mpi=$mpi_check
      [[ -z $mpi ]] || module load hpc-$HPC_MPI
      module load netcdf
      ;;
    wgrib2)
      mpi=$mpi_check
      [[ -z $mpi ]] || module load hpc-$HPC_MPI
      module try-load jasper
      module try-load png
      module load netcdf
      module load ip2
      ;;
    ip2)
      module load sp
      ;;
    g2)
      module try-load png
      module try-load jasper
      ;;
    nemsio)
      mpi=$mpi_check
      [[ -z $mpi ]] && ( echo "$name requires MPI, ABORT!"; exit 1 )
      module load hpc-$HPC_MPI
      module load bacio
      module load w3nco
      ;;
    nemsiogfs)
      mpi=$mpi_check
      [[ -z $mpi ]] && ( echo "$name requires MPI, ABORT!"; exit 1 )
      module load hpc-$HPC_MPI
      module load nemsio
      ;;
    w3emc)
      mpi=$mpi_check
      [[ -z $mpi ]] && ( echo "$name requires MPI, ABORT!"; exit 1 )
      module load hpc-$HPC_MPI
      module load sigio
      module load nemsio
      ;;
    nceppost)
      mpi=$mpi_check
      [[ -z $mpi ]] && ( echo "$name requires MPI, ABORT!"; exit 1 )
      module load hpc-$HPC_MPI
      module try-load png
      module try-load jasper
      module load bacio
      module load sigio
      module load sfcio
      module load gfsio
      module load w3nco
      module load nemsio
      module load g2
      module load g2tmpl
      module load ip
      module load sp
      module load w3emc
      module load crtm
      ;;
  esac
  module list
  set -x

  prefix="${PREFIX:-"/opt/modules"}/$compiler/$mpi/$name/$install_as"
  if [[ -d $prefix ]]; then
    [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix; $SUDO mkdir $prefix ) \
                               || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
  fi

else
    eval prefix="\${${name}_ROOT:-'/usr/local'}"
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

# Set properties based on library name
case $name in
  nceppost)
    gitURL="https://github.com/noaa-emc/emc_post"
    extraCMakeFlags=""
    ;;
  crtm)
    gitURL="https://github.com/noaa-emc/emc_crtm"
    extraCMakeFlags=""
    ;;
  *)
    gitURL="https://github.com/noaa-emc/nceplibs-$name"
    extraCMakeFlags=""
    ;;
esac

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

software=$name-$version
[[ -d $software ]] || ( git clone -b $version $gitURL $software )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

cmake .. \
  -DCMAKE_INSTALL_PREFIX=$prefix \
  -DENABLE_TESTS=OFF \
  $extraCMakeFlags \
  -DOPENMP=${OPENMP}

VERBOSE=$MAKE_VERBOSE make -j${NTHREADS:-4}
[[ $MAKE_CHECK =~ [yYtT] ]] && make check
[[ $USE_SUDO =~ [yYtT] ]] && sudo -- bash -c "export PATH=$PATH; make install" \
                          || make install

# generate modulefile from template
[[ -z $mpi ]] && modpath=compiler || modpath=mpi
$MODULES && update_modules $modpath $name $install_as \
         || echo $name $version >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
