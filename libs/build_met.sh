#!/bin/bash    

set -eux

name="met"
version=${1:-${STACK_met_version}}
release_date=${2:-${STACK_met_release_date}}

# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')
mpi=$(echo $HPC_MPI | sed 's/\//-/g')

[[ $STACK_met_enable_python =~ [yYtT] ]] && enable_python=YES || enable_python=NO

if $MODULES; then
    set +x
    source $MODULESHOME/init/bash
    module load hpc-$HPC_COMPILER
    [[ -z $mpi ]] || module load hpc-$HPC_MPI
    [[ $enable_python =~ [yYtT] ]] && module load hpc-$HPC_PYTHON
    module load bufr
    module load zlib
    module load jasper
    module load png
    module load g2c
    module load gsl
    module load hdf5
    module load netcdf
    module list
    set -x
    prefix="${PREFIX:-"/opt/modules"}/$compiler/$mpi/$name/$version"
    if [[ -d $prefix ]]; then
	[[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix ) \
	    || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
    fi
else

    prefix=${MET_ROOT:-"/usr/local"}

fi

export MET_BASE=$prefix/share/met

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
export FFLAGS="${STACK_FFLAGS:-} ${STACK_met_FFLAGS:-}"
export CFLAGS="${STACK_CFLAGS:-} ${STACK_met_CFLAGS:-}"

export CFLAGS+="-D__64BIT__"
export CXXFLAGS+="-D__64BIT__"

export MET_NETCDF=${NETCDF_ROOT}
export MET_HDF5=${HDF5_ROOT}

bufr_libdir=`find ${BUFR_ROOT:-${bufr_ROOT}} -name libbufr_4.a -exec dirname {} \;`
export MET_BUFRLIB=$bufr_libdir
g2c_libdir=`find ${G2C_ROOT:-${g2c_ROOT}} -name libg2c.a -exec dirname {} \;`
export MET_GRIB2CLIB=$g2c_libdir
export MET_GRIB2CINC=${G2C_ROOT:-${g2c_ROOT}}/include
export MET_GSL=${GSL_ROOT:-${gsl_ROOT}}
export BUFRLIB_NAME=-lbufr_4
export GRIB2CLIB_NAME=-lg2c
jasper_libdir=`find ${JASPER_ROOT} -name libjasper.a -exec dirname {} \;`
export LIB_JASPER=$jasper_libdir

export LIB_LIBPNG=${PNG_ROOT}/lib
export LIB_Z=${ZLIB_ROOT}/lib



if [[ $enable_python =~ [yYtT] ]]; then
    export MET_PYTHON=${MET_PYTHON:-`which python3`}

    if [[ -z ${MET_PYTHON_CC+x} ]]; then
        #export MET_PYTHON_CC=`$MET_PYTHON_CONFIG --cflags`
        echo "Set MET_PYTHON_CC to include 'Python.h' usually through 'python3-config --cflfags'"
        exit
    fi

    if [[ -z ${MET_PYTHON_LD+x} ]]; then
        #export MET_PYTHON_LD=`$MET_PYTHON_CONFIG --ldflags`
        echo "Set MET_PYTHON_LD to to link to libpython through 'python3-config --ldflags"
        exit
    fi
fi

LDFLAGS2="-L${MET_NETCDF}/lib -L${MET_HDF5}/lib -L${MET_BUFRLIB}"
LDFLAGS3="-L${MET_GRIB2CLIB} -L${MET_GSL}/lib"
LDFLAGS4="-L${LIB_JASPER} -L${MET_HDF5}/lib -L${LIB_LIBPNG} -L${LIB_Z}"

export LDFLAGS="-fPIE ${LDFLAGS2:-} ${LDFLAGS3:-} ${LDFLAGS4:-}"
export LIBS="-lhdf5_hl -lhdf5 -lz"

cd  ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}
software=$name-$version.$release_date
pkg_name=$name-$version
url="https://github.com/dtcenter/MET/releases/download/v$version/$software.tar.gz"
[[ -d $software ]] || ( $WGET $url; tar -xf $software.tar.gz )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $pkg_name ]] && cd $pkg_name || ( echo "$pkg_name does not exist, ABORT!"; exit 1 )

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}/${pkg_name}
curr_dir=$(pwd)


extra_flags="--enable-grib2 "
[[ $enable_python =~ [yYtT] ]] && extra_flags+="--enable-python "
./configure --prefix=$prefix BUFRLIB_NAME=${BUFRLIB_NAME} GRIB2CLIB_NAME=${GRIB2CLIB_NAME} ${extra_flags:-}

make
[[ $MAKE_CHECK =~ [yYtT] ]] && make check
$SUDO make install

# generate modulefile from template
[[ -z $mpi ]] && modpath=compiler || modpath=mpi
$MODULES && update_modules $modpath $name $version_install
echo $name $version_install $URL >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
