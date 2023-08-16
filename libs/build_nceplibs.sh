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
    crtm | nemsiogfs | ncio | ncdiag)
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
                  [[ ! -z $mpi ]] || exit 0
                  module load hpc-$HPC_MPI
                  using_mpi=YES
                  w3dep="w3nco"
              fi
          fi
      fi
      if [[ $using_mpi = "UNKNOWN" ]]; then
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
    wrf_io )
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
    crtm)
      module load netcdf
      ;;
    ip | ip2)
      module load sp
      ;;
    g2)
      module try-load jpeg
      module try-load libpng
      module try-load jasper
      ;;
    g2c)
      module try-load jpeg
      module try-load zlib
      module try-load libpng
      module try-load jasper
      ;;
    nemsio)
      module load bacio
      module load ${w3dep}
      ;;
    nemsiogfs)
      module load nemsio
      module load w3nco
      ;;
    w3emc)
      module load bacio
      if [[ "$using_mpi" =~ [yYtT] ]]; then
          module load netcdf
          module load sigio
          module load nemsio
      fi
      ;;
    grib_util)
      module try-load jpeg
      module try-load jasper
      module try-load zlib
      module try-load libpng
      module try-load w3emc/2.9.2
      module load bacio
      module load w3nco
      module load g2
      module load ip
      module load sp
      ;;
    prod_util)
      module load w3nco
      ;;
    ncio | ncdiag)
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
      if [[ $OVERWRITE =~ [yYtT] ]]; then
          echo "WARNING: $prefix EXISTS: OVERWRITING!"
          $SUDO rm -rf $prefix
          $SUDO mkdir $prefix
      else
          echo "WARNING: $prefix EXISTS, SKIPPING"
          exit 0
      fi
  fi

else

  nameUpper=$(echo $name | tr [a-z] [A-Z])
  eval prefix="\${${nameUpper}_ROOT:-'/usr/local'}"
  case $name in
    # The following require MPI
    nemsio | nemsiogfs | ncio | ncdiag )
      using_mpi=YES
      ;;
    # The following can use MPI (if available)
    wrf_io )
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
  crtm)
    URL="https://github.com/NOAA-EMC/crtm.git"
    ;;
  bufr)
    if [[ ${using_python:-} =~ [yYtT] ]]; then
      extraCMakeFlags="-DENABLE_PYTHON=ON "
    fi
    if [[ $MAKE_CHECK =~ [yYtT] ]]; then
        extraCMakeFlags+="-DBUILD_TESTS=ON"
    else
        extraCMakeFlags+="-DBUILD_TESTS=OFF"
    fi
    ;;
  nemsio)
    if [[ ${using_mpi:-} =~ [yYtT] ]]; then
      extraCMakeFlags="-DENABLE_MPI=ON"
    else
      extraCMakeFlags="-DENABLE_MPI=OFF"
    fi
    ;;
  ncdiag)
    URL="https://github.com/NOAA-EMC/GSI-ncdiag"
    ;;
  prod_util)
    min_version="2.0.13"
    min_version2="2.0.14"
    if [ "$(printf '%s\n' "$min_version" "$install_as" | sort -V | head -n1)" = "$min_version" ]; then 
       # echo "min_version is $min_version";
       URL="git@github.com:NCEP-NCO/prod_util.git"
    fi
    if [ "$(printf '%s\n' "$min_version2" "$install_as" | sort -V | head -n1)" = "$min_version2" ]; then 
       URL="https://www.nco.ncep.noaa.gov/pmb/codes/nwprod/prod_util.${version}/"
    fi
    ;;
esac

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

software=$name-$version
if [[ ${name} == "prod_util"  &&  "$(printf '%s\n' "$min_version2" "$install_as" | sort -V | head -n1)" = "$min_version2" ]] ; then
   if [[ ! -d $software ]]; then
     mkdir $software
     cd $software
     wget --recursive --convert-links --quiet --no-parent -nH --cut-dirs=4 -E -R html $URL
   fi
else
   if [[ ! -d $software ]]; then
     export GIT_LFS_SKIP_SMUDGE=1
     git clone $URL $software
     cd $software
     if [[ "$name" == "crtm" ]]; then
       version=release/REL-${install_as}_emc
     fi
     git checkout $version
     git submodule update --init --recursive
   fi
fi

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

# Download CRTM fix files
if [[ "$name" == "crtm" ]]; then
  if [[ ${STACK_crtm_install_fix:-} =~ [yYtT] ]]; then
    if [[ ! -d crtm_fix-${install_as} ]]; then
      crtm_tarball=fix_REL-${install_as}_emc.tgz
      [[ -f $crtm_tarball ]] || ( $WGET http://ftp.ssec.wisc.edu/pub/s4/CRTM/$crtm_tarball )
      tar xzf $crtm_tarball
      [[ "${install_as}" == "2.3.0" ]] && mv fix_REL-${install_as}_emc crtm_fix-${install_as}
      [[ "${install_as}" == "2.4.0" ]] && mv crtm-internal_REL-${install_as}_emc/fix crtm_fix-${install_as}
      rm -f $crtm_tarball
    fi
  fi
fi

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
# A block below with the correction may be needed for certain non-Linux systems (e.g., Gaea/Cray) 
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

if [[ ${name} == "prod_util"  &&  "$(printf '%s\n' "$min_version" "$install_as" | sort -V | head -n1)" = "$min_version" ]] ; then
   mkdir bin
   cd ../sorc
   for dir in fsync_file.cd  mdate.fd  ndate.fd  nhour.fd; do
     cd $dir 
     sed -i "s:ifort:${FC}:" makefile
     sed -i "s:icc:${CC}:" makefile
     exe=${dir/.*/}
     rm -f $exe
     make
     if [ $? -eq 0 ]; then
       mv $exe ../../build/bin/.
     fi
     cd ..
   done
   if [ $? -eq 0 ]; then
      cp -r ../ush/* ../build/bin/.
      [[ ! -d $prefix ]] && mkdir $prefix
      mv ../build/bin $prefix/.
   fi
   [[ $USE_SUDO =~ [yYtT] ]] && sudo -- bash -c "export PATH=$PATH" 
else
    cmake .. \
  -DCMAKE_INSTALL_PREFIX=$prefix -DCMAKE_Fortran_COMPILER=${FC} \
  -DENABLE_TESTS=OFF -DOPENMP=${openmp} ${extraCMakeFlags:-}

  VERBOSE=$MAKE_VERBOSE make -j${NTHREADS:-4}
  [[ $MAKE_CHECK =~ [yYtT] ]] && make check
  [[ $USE_SUDO =~ [yYtT] ]] && sudo -- bash -c "export PATH=$PATH; make install" \
                          || make install
fi
cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

# Install CRTM fix files
if [[ "$name" == "crtm" ]]; then
  if [[ ${STACK_crtm_install_fix:-} =~ [yYtT] ]]; then
    if [[ -d crtm_fix-${install_as} ]]; then
      mkdir -p $prefix/fix
      find ./crtm_fix-${install_as} -type f \( -path '*/Big_Endian/*' -o -path '*/netcdf/*' -o -path '*/netCDF/*' \) -not -path '*/Little_Endian/*' -exec cp -p {} $prefix/fix \;
      mv $prefix/fix/amsua_metop-c.SpcCoeff.bin $prefix/fix/amsua_metop-c.SpcCoeff.noACC.bin
      cp -p ./crtm_fix-${install_as}/SpcCoeff/Little_Endian/amsua_metop-c_v2.SpcCoeff.bin $prefix/fix/amsua_metop-c.SpcCoeff.bin
    fi
  fi
fi

# generate modulefile from template
[[ ${using_mpi:-} =~ [yYtT] ]] && modpath=mpi || modpath=compiler
[[ ${using_python:-} =~ [yYtT] ]] && py_version="$(python3 --version | cut -d " " -f2 | cut -d. -f1-2)"
$MODULES && update_modules $modpath $name $install_as ${py_version:-}
echo $name $version $URL >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
