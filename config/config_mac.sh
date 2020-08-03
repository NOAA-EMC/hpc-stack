#!/bin/bash

# Compiler/MPI combination
export JEDI_COMPILER="clang/11.0.0"
#export JEDI_MPI="openmpi/4.0.3"
export JEDI_MPI="mpich/3.3.1"

# This tells jedi-stack how you want to build the compiler and mpi modules
# valid options include:
# native-module: load a pre-existing module (common for HPC systems)
# native-pkg: use pre-installed executables located in /usr/bin or /usr/local/bin,
#             as installed by package managers like apt-get or hombrewo.
#             This is a common option for, e.g., gcc/g++/gfortrant
# from-source: This is to build from source
export COMPILER_BUILD="native-pkg"
export MPI_BUILD="from-source"

# Build options
export PREFIX=/opt/modules
export USE_SUDO=Y
export PKGDIR=pkg
export LOGDIR=buildscripts/log
export OVERWRITE=Y
export NTHREADS=4
export   MAKE_CHECK=N
export MAKE_VERBOSE=Y
export   MAKE_CLEAN=N
export DOWNLOAD_ONLY=F
export STACK_EXIT_ON_FAIL=T
export WGET="wget -nv"

# Minimal JEDI Stack
export      STACK_BUILD_CMAKE=N
export       STACK_BUILD_SZIP=Y
export    STACK_BUILD_UDUNITS=Y
export       STACK_BUILD_ZLIB=Y
export     STACK_BUILD_LAPACK=Y
export STACK_BUILD_BOOST_HDRS=Y
export     STACK_BUILD_EIGEN3=Y
export       STACK_BUILD_HDF5=Y
export    STACK_BUILD_PNETCDF=Y
export     STACK_BUILD_NETCDF=Y
export      STACK_BUILD_NCCMP=Y
export        STACK_BUILD_NCO=Y
export    STACK_BUILD_ECBUILD=Y
export      STACK_BUILD_ECKIT=Y
export      STACK_BUILD_FCKIT=N
export      STACK_BUILD_ATLAS=N
export        STACK_BUILD_ODC=Y
export    STACK_BUILD_BUFRLIB=Y

# Optional Additions
export           STACK_BUILD_PIO=Y
export          STACK_BUILD_GPTL=N
export        STACK_BUILD_PYJEDI=N
export      STACK_BUILD_PYBIND11=Y
export      STACK_BUILD_HPCLIBS=N
export          STACK_BUILD_JPEG=N
export           STACK_BUILD_PNG=N
export        STACK_BUILD_JASPER=N
export     STACK_BUILD_ARMADILLO=N
export        STACK_BUILD_XERCES=N
export        STACK_BUILD_TKDIFF=N
export    STACK_BUILD_BOOST_FULL=N
export          STACK_BUILD_ESMF=N
export      STACK_BUILD_BASELIBS=N
export     STACK_BUILD_PDTOOLKIT=N
export          STACK_BUILD_TAU2=N
export          STACK_BUILD_CGAL=N

