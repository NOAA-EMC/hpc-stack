#!/bin/bash

set -eux

name="tau2"
version=${1:-${STACK_tau2_version}}

# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')
mpi=$(echo $HPC_MPI | sed 's/\//-/g')

# manage package dependencies here
if $MODULES; then
    set +x
    source $MODULESHOME/init/bash
    module load hpc-$HPC_COMPILER
    module load hpc-$HPC_MPI
    module load pdtoolkit
    module load zlib
    module list
    set -x

    prefix="${PREFIX:-"/opt/modules"}/$compiler/$mpi/$name/$version"
    if [[ -d $prefix ]]; then
        [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix ) \
                                   || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
    fi
else
    prefix=${TAU_ROOT:-"/usr/local/$name/$version"}
fi

export CC=${MPI_CC:-"mpicc"}
export CXX=${MPI_CXX:-"mpiicpc"}
if [[ $MPI_FC = "mpifort" ]]; then
    export FC="mpif90"
else
    export FC=${MPI_FC:-"mpif90"}
fi

export PDTOOLKIT_ROOT=$PDT_ROOT

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

software=tau2
[[ -d $PDTOOLKIT_ROOT ]] || ( echo "$software requires pdtoolkit, ABORT!"; exit 1 )
[[ -d $software ]] || git clone https://github.com/UO-OACISS/tau2
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build

$SUDO ./configure -prefix=$prefix -c++=$CXX -cc=$CC -fortran=$FC -mpi -ompt -bfd=download \
                  -dwarf=download -unwind=download -iowrapper -pdt=$PDTOOLKIT_ROOT

#                  -arch=x86_64

# Note - if this doesn't work you might have to run the entire script as root
$SUDO make install

# generate modulefile from template
$MODULES && update_modules mpi $name $version \
         || echo $name $version >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
