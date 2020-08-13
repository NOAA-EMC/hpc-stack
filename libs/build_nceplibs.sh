#!/bin/bash

set -ex

name=$1
eval s_version="\${STACK_${name}_version}"
eval s_install_as="\${STACK_${name}_install_as}"
eval s_openmp="\${STACK_${name}_openmp}"
version=${2:-$s_version}    # second column of COMPONENTS
install_as=${3:-${s_install_as}} #  third column of COMPONENTS
openmp=${4:-${s_openmp:-"OFF"}}

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
      module load netcdf/${STACK_netcdf_version}
      ;;
    wgrib2)
      mpi=$mpi_check
      [[ -z $mpi ]] || module load hpc-$HPC_MPI
      module try-load jasper/${STACK_jasper_version}
      module try-load zlib/${STACK_zlib_version}
      module try-load png/${STACK_png_version}
      module load netcdf/${STACK_netcdf_version}
      module load ip2/${STACK_ip2_version}
      ;;
    ip2)
      module load sp/${STACK_sp_version}
      ;;
    g2)
      module try-load png/${STACK_png_version}
      module try-load jasper/${STACK_jasper_version}
      ;;
    nemsio)
      mpi=$mpi_check
      [[ -z $mpi ]] && ( echo "$name requires MPI, ABORT!"; exit 1 )
      module load hpc-$HPC_MPI
      module load bacio/${STACK_bacio_version}
      module load w3nco/${STACK_w3nco_version}
      ;;
    nemsiogfs)
      mpi=$mpi_check
      [[ -z $mpi ]] && ( echo "$name requires MPI, ABORT!"; exit 1 )
      module load hpc-$HPC_MPI
      module load nemsio/${STACK_nemsio_version}
      ;;
    w3emc)
      mpi=$mpi_check
      [[ -z $mpi ]] && ( echo "$name requires MPI, ABORT!"; exit 1 )
      module load hpc-$HPC_MPI
      module load netcdf/${STACK_netcdf_version}
      module load sigio/${STACK_sigio_version}
      module load nemsio/${STACK_nemsio_version}
      ;;
    nceppost)
      mpi=$mpi_check
      [[ -z $mpi ]] && ( echo "$name requires MPI, ABORT!"; exit 1 )
      module load hpc-$HPC_MPI
      module try-load png/${STACK_png_version}
      module try-load jasper/${STACK_jasper_version}
      module load netcdf/${STACK_netcdf_version}
      module load bacio/${STACK_bacio_version}
      module load w3nco/${STACK_w3nco_version}
      module load g2/${STACK_g2_version}
      module load g2tmpl/${STACK_g2tmpl_version}
      module load ip/${STACK_ip_version}
      module load sp/${STACK_sp_version}
      module load w3emc/${STACK_w3emc_version}
      module load crtm/${STACK_crtm_version}
      # post executable requires the following,
      # but we are not building post executable
      # module load sigio/${STACK_sigio_version}
      # module load sfcio/${STACK_sfcio_version}
      # module load gfsio/${STACK_gfsio_version}
      # module load nemsio/${STACK_nemsio_version}
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
    nameUpper=$(echo $name | tr [a-z] [A-Z])
    eval prefix="\${${nameUpper}_ROOT:-'/usr/local'}"
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
    extraCMakeFlags="-DBUILD_POSTEXEC=OFF"
    ;;
  crtm)
    gitURL="https://github.com/noaa-emc/emc_crtm"
    ;;
  *)
    gitURL="https://github.com/noaa-emc/nceplibs-$name"
    extraCMakeFlags=""
    ;;
esac

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

software=$name-$version
#[[ -d $software ]] || ( git clone --recursive -b $version $gitURL $software )
if [[ ! -d $software ]]; then
  git clone $gitURL $software
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
  -DENABLE_TESTS=OFF \
  $extraCMakeFlags \
  -DOPENMP=${openmp}

VERBOSE=$MAKE_VERBOSE make -j${NTHREADS:-4}
[[ $MAKE_CHECK =~ [yYtT] ]] && make check
[[ $USE_SUDO =~ [yYtT] ]] && sudo -- bash -c "export PATH=$PATH; make install" \
                          || make install

# generate modulefile from template
[[ -z $mpi ]] && modpath=compiler || modpath=mpi
$MODULES && update_modules $modpath $name $install_as \
         || echo $name $version >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
