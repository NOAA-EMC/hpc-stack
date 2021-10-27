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
    nemsiogfs | ncio | nceppost | upp)
      module load hpc-$HPC_MPI
      using_mpi=YES
      ;;
    nemsio)
      version_number=$(echo $version | cut -c 2-)
      major_ver=$(echo $version_number | cut -d. -f1)
      minor_ver=$(echo $version_number | cut -d. -f2)
      patch_ver=$(echo $version_number | cut -d. -f3)
      using_mpi=UNKNOWN
      if [[ "$major_ver" -le "2" ]]; then
          if [[ "$minor_ver" -le "5" ]]; then
              if [[ "$patch_ver" -lt "3" ]]; then
                  [[ ! -z $mpi ]] || (echo nemsio $version_number requires MPI. SKIPPING!; exit 0)
                  module load hpc-$HPC_MPI
                  using_mpi=YES
                  w3dep="w3nco"
              fi
          fi
      fi
      if [[ $using_MPI = "UNKNOWN" ]]; then
        w3dep="w3emc"
        using_mpi=NO
        if [[ ! -z $mpi ]]; then
          module load hpc-$HPC_MPI
          using_mpi=YES
        fi
      fi
      ;;
    w3emc)
      version_number=$(echo $version | cut -c 2-)
      major_ver=$(echo $version_number | cut -d. -f1)
      minor_ver=$(echo $version_number | cut -d. -f2)
      using_mpi=NO
      if [[ "$major_ver" -le "2" ]]; then
          if [[ "$minor_ver" -lt "9" ]]; then
              module load hpc-$HPC_MPI
              using_mpi=YES
          fi
      fi
      ;;
    # The following can use MPI (if available)
    wrf_io | wgrib2)
      if [[ ! -z $mpi ]]; then
        module load hpc-$HPC_MPI
        using_mpi=YES
      fi
      ;;
  esac

  # Load dependencies
  case $name in
    wrf_io)
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
      module try-load zlib
      module try-load png
      module try-load jasper
      ;;
    nemsio)
      module load bacio
      module load ${w3dep}
      ;;
    nemsiogfs)
      module load nemsio
      ;;
    w3emc)
      if [[ "$using_mpi" =~ [yYtT] ]]; then
          module load netcdf
          module load sigio
          module load nemsio
      fi
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
    wrf_io | wgrib2)
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
    URL="https://github.com/noaa-emc/upp"
    extraCMakeFlags="-DBUILD_POSTEXEC=OFF"
    ;;
  crtm)
    URL="https://github.com/noaa-emc/emc_crtm"
    ;;
  wgrib2)
    extraCMakeFlags="${STACK_wgrib2_cmake_opts:-}"
    ;;
  bufr)
    if [[ ${using_python:-} =~ [yYtT] ]]; then
      extraCMakeFlags="-DENABLE_PYTHON=ON"
    fi
    ;;
esac

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

software=$name-$version
if [[ ! -d $software ]]; then
  git clone $URL $software
  cd $software
  git checkout $version
  git submodule update --init --recursive
fi

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

# Download CRTM fix files
if [[ "$name" == "crtm" ]]; then
  if [[ ${STACK_crtm_install_fix:-} =~ [yYtT] ]]; then
    if [[ ! -d crtm_fix-$version ]]; then
      crtm_tarball=fix_REL-${install_as}_emc.tgz
      rm -f $crtm_tarball
      $WGET ftp://ftp.ucar.edu/pub/cpaess/bjohns/$crtm_tarball
      tar xzf $crtm_tarball
      mv fix crtm_fix-$version
      rm -f $crtm_tarball
    fi
    if [[ ! -f link_crtm_coeffs.sh ]]; then
      $WGET https://raw.githubusercontent.com/NOAA-EMC/GSI/master/ush/link_crtm_coeffs.sh
      sed -i'.backup' -e 's/LINK="ln -sf"/LINK="cp"/g' link_crtm_coeffs.sh
      chmod +x link_crtm_coeffs.sh
      rm -f link_crtm_coeffs.sh.backup
    fi
  fi
fi

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

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

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

# Install CRTM fix files
if [[ "$name" == "crtm" ]]; then
  if [[ ${STACK_crtm_install_fix:-} =~ [yYtT] ]]; then
    if [[ -d crtm_fix-$version ]]; then
      ./link_crtm_coeffs.sh ./crtm_fix-$version $prefix/fix
    fi
  fi
fi

# generate modulefile from template
[[ ${using_mpi:-} =~ [yYtT] ]] && modpath=mpi || modpath=compiler
[[ ${using_python:-} =~ [yYtT] ]] && py_version="$(python3 --version | cut -d " " -f2 | cut -d. -f1-2)"
$MODULES && update_modules $modpath $name $install_as ${py_version:-}
echo $name $version $URL >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
