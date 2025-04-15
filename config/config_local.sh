#!/bin/bash
set -x
#dont allow xtrace as modules are sourced and super messy to look at
if [[ "$-" =~ "x" ]]; then XTRACE_COMMAND="set -x" ;else XTRACE_COMMAND=":" ;fi

# Compiler/MPI combination
export HPC_COMPILER="intel/19.1.3.304"
export HPC_COMPILER="intel/19.1.3.304"
export HPC_MPI="cray-mpich/8.1.19"
export HPC_PYTHON="python/3.10.4"

export GSL_ROOT=/apps/spack/gsl/2.7/intel/19.1.3.304/xks7dxbowrdxhjck5zxc4rompopocev
# Build options
export USE_SUDO=N
export PKGDIR=pkg
export LOGDIR=log
export OVERWRITE=N
export NTHREADS=8
export   MAKE_CHECK=N
export MAKE_VERBOSE=N
export   MAKE_CLEAN=N
export DOWNLOAD_ONLY=F
export STACK_EXIT_ON_FAIL=Y
export WGET='wget -nv'

            
# BASH_ENV loads Cray modules each time a new script starts
# Disable that so LMOD isn't overwritten
unset BASH_ENV

set +x
module purge
module load envvar  #sets up the basics on WCOSS2
#unset HPC_OPT  #envar assumes /apps/ops programs are installed
prgenv=intel # just a little trickyness because cray != cce
prgenv=${prgenv%-*} # prgenv doesnt have a classic or oneapi yet
module load PrgEnv-${prgenv}
module load craype
module load intel/19.1.3.304
module load cray-mpich/8.1.19
module load cmake
module load git
#module load python
$XTRACE_COMMAND

export CC=cc
export FC=ftn
export CXX=CC
export SERIAL_CC=${CC}
export SERIAL_FC=${FC}
export SERIAL_CXX=${CXX}
export MPI_CC=$SERIAL_CC
export MPI_FC=$SERIAL_FC
export MPI_CXX=$SERIAL_CXX
export ESMF_CC=$SERIAL_CC
export ESMF_FC=$SERIAL_FC
export ESMF_CXX=$SERIAL_CXX

#this is to get the hdf5 libraries into a lib directory instead of a lib64 directory
export CONFIG_SITE="/apps/prod/hpc-stack/build/config.site/x86_64-unknown-linux-gnu"
# might be needed for new hpc-stack versions
export g2_DIR=/apps/prod/hpc-stack/build/localbuild/i-19.1.3.304__m-8.1.19__h-1.14.0__n-4.9.2__p-2.5.10__e-8.8.0_pnetcdf/hpc-stack/pkg/g2-v3.4.3/build
export g2tmpl_DIR=/apps/prod/hpc-stack/i-19.1.3.304__m-8.1.19__h-1.14.0__n-4.9.2__p-2.5.10__e-8.8.0_pnetcdf/intel-19.1.3.304/g2tmpl/1.10.0/lib/cmake/g2tmpl
export ip_DIR=/apps/prod/hpc-stack/i-19.1.3.304__m-8.1.19__h-1.14.0__n-4.9.2__p-2.5.10__e-8.8.0_pnetcdf/intel-19.1.3.304/ip/3.3.3/lib/cmake/ip
#set +x
#module use /apps/prod/hpc-stack/i-19.1.3.304__m-8.1.19__h-1.14.0__n-4.9.2__p-2.5.10__e-8.8.0_pnetcdf/modulefiles/mpi/${HPC_COMPILER}/${HPC_MPI}/esmf
#$XTRACE_COMMAND

            

export ESMF_COMMPILER=intel #
# Define the ESMF_COMM variable for WCOSS2
# This is necessary to be done here rather than stack_noaa.yaml, to keep one YAML file for NOAA.
STACK_esmf_version=8.8.0
STACK_esmf_install_as=${STACK_esmf_version}
export STACK_esmf_comm=mpich
export STACK_esmf_os=Linux
#export STACK_mapl_esmf_version=8_8_0
export STACK_mapl_esmf_version=8.8.0

export STACK_netcdf_version_c=4.9.2
#export ESMF_VERSION=8.8.0
#FMS to build with AVX:
export STACK_fms_CFLAGS="-march=core-avx2"
export STACK_fms_FFLAGS="-march=core-avx2"

export STACK_atlas_version=0.38.1
export STACK_atlas_repo=ecmwf


#hack
LD_LIBRARY_PATH=/opt/cray/lib64:/opt/cray/pe/mpich/8.1.19/ofi/intel/19.0/lib




            

export STACK_esmf_enable_pnetcdf=yes
export STACK_netcdf_enable_pnetcdf=yes

            
