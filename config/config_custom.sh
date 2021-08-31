#!/bin/bash

# Compiler/MPI combination
export HPC_COMPILER="gnu/9.4.0"
export HPC_MPI="mpich/3.4.2"
export HPC_PYTHON="python/3.8.8"

# Build options
export USE_SUDO=N
export PKGDIR=pkg
export LOGDIR=log
export OVERWRITE=N
export NTHREADS=20
export   MAKE_CHECK=N
export MAKE_VERBOSE=N
export   MAKE_CLEAN=N
export DOWNLOAD_ONLY=N
export STACK_EXIT_ON_FAIL=Y
export WGET="wget -nv"


export MET_PYTHON_CC="-I/opt/local/Library/Frameworks/Python.framework/Versions/3.8/include/python3.8"
export MET_PYTHON_LD="-L/Users/KIG/opt/anaconda3/lib/python3.8/config-3.8-darwin -lpython3.8 -ldl -framework CoreFoundation"

#export MET_PYTHON_CONFIG=`which python3-config`
#export MET_PYTHON=`which python3`

#export MET_PYTHON_CC=
#export MET_PYTHON_LD=
