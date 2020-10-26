#!/bin/bash

function update_modules {
  local prefix=${PREFIX:-${HPC_OPT:-"/usr/local"}}
  local modpath=$1
  local name=$2
  local version=$3
  case $modpath in
    core )
      local tmpl_file=$HPC_STACK_ROOT/modulefiles/core/$name/$name.lua
      local to_dir=$prefix/modulefiles/core
      ;;
    compiler )
      local tmpl_file=$HPC_STACK_ROOT/modulefiles/compiler/compilerName/compilerVersion/$name/$name.lua
      local to_dir=$prefix/modulefiles/compiler/$HPC_COMPILER
      ;;
    mpi )
      local tmpl_file=$HPC_STACK_ROOT/modulefiles/mpi/compilerName/compilerVersion/mpiName/mpiVersion/$name/$name.lua
      local to_dir=$prefix/modulefiles/mpi/$HPC_COMPILER/$HPC_MPI
      ;;
    * )
      echo "ERROR: INVALID MODULE PATH, ABORT!"
      exit 1
      ;;
  esac

  [[ -e $tmpl_file ]] || ( echo "ERROR: $tmpl_file NOT FOUND! ABORT!"; exit 1 )
  [[ -d $to_dir ]] || ( echo "ERROR: $mod_dir MODULE DIRECTORY NOT FOUND! ABORT!"; exit 1 )

  cd $to_dir
  $SUDO mkdir -p $name; cd $name
  $SUDO cp $tmpl_file $version.lua

  # Make the latest installed version the default
  [[ -e default ]] && $SUDO rm -f default
  $SUDO ln -s $version.lua default
}

function no_modules {

  echo "=========================="
  echo "no_modules()"
  # this function defines environment variables that are
  # normally done by the modules.
  # It's mainly intended for use when not using LMod

  local compilerName=$(echo $HPC_COMPILER | cut -d/ -f1)
  local mpiName=$(echo $HPC_MPI | cut -d/ -f1)

  # these can be specified in the config file
  # so these should be considered defaults

  case $compilerName in
    gnu|gcc )
      export SERIAL_CC=${SERIAL_CC:-"gcc"}
      export SERIAL_CXX=${SERIAL_CXX:-"g++"}
      export SERIAL_FC=${SERIAL_FC:-"gfortran"}
      ;;
    intel|ips )
      export SERIAL_CC=${SERIAL_CC:-"icc"}
      export SERIAL_CXX=${SERIAL_CXX:-"icpc"}
      export SERIAL_FC=${SERIAL_FC:-"ifort"}
      ;;
    clang )
      export SERIAL_CC=${SERIAL_CC:-"clang"}
      export SERIAL_CXX=${SERIAL_CXX:-"clang++"}
      export SERIAL_FC=${SERIAL_FC:-"gfortran"}
      ;;
    cray | cray* )
      export SERIAL_CC=${SERIAL_CC:-"cc"}
      export SERIAL_CXX=${SERIAL_CXX:-"CC"}
      export SERIAL_FC=${SERIAL_FC:-"ftn"}
      ;;
    * )
      echo "Unknown compiler option = $compilerName, ABORT!"
      local abort=Y
      ;;
  esac

  case $mpiName in
    openmpi | mpich )
      export MPI_CC=${MPI_CC:-"mpicc"}
      export MPI_CXX=${MPI_CXX:-"mpicxx"}
      export MPI_FC=${MPI_FC:-"mpifort"}
      ;;
    impi )
      export MPI_CC=${MPI_CC:-"mpiicc"}
      export MPI_CXX=${MPI_CXX:-"mpiicpc"}
      export MPI_FC=${MPI_FC:-"mpiifort"}
      ;;
    cray | cray* )
      export MPI_CC=${MPI_CC:-"cc"}
      export MPI_CXX=${MPI_CXX:-"CC"}
      export MPI_FC=${MPI_FC:-"ftn"}
      ;;
    * )
      echo "Unknown MPI option = $mpiName, ABORT!"
      local abort=Y
      ;;
  esac

  echo "C Compiler: $SERIAL_CC"
  echo "C++ Compiler: $SERIAL_CXX"
  echo "Fortran Compiler: $SERIAL_FC"
  echo
  echo "MPI C Compiler: $MPI_CC"
  echo "MPI C++ Compiler: $MPI_CXX"
  echo "MPI Fortran Compiler: $MPI_FC"

  [[ ${abort:-} =~ [yYtT] ]] && exit 1

  echo "=========================="
}

function set_pkg_root() {
  # export <PKG>_ROOT environment variables
  echo "=========================="
  echo "set_pkg_root()"
  local prefix=${PREFIX:-${HPC_OPT:-"/usr/local"}}
  for i in $(printenv | grep "STACK_.*_build="); do
    local pkg=$(echo $i | cut -d= -f1 | tr 'a-z' 'A-Z' | cut -d_ -f2- | rev | cut -d_ -f2- | rev)
    local build=$(echo $i | cut -d= -f2)
    if [[ $build =~ ^(yes|YES|true|TRUE)$ ]]; then
      eval export ${pkg}_ROOT=$prefix
      local var="${pkg}_ROOT"
      echo "${pkg}_ROOT = ${!var}"
    fi
  done
  echo "=========================="
}

function set_no_modules_path() {
  # add $PREFIX to PATH, LD_LIBRARY_PATH and CMAKE_PREFIX_PATH
  echo "=========================="
  echo "set_no_modules_path()"
  local prefix=${PREFIX:-${HPC_OPT:-"/usr/local"}}
  export PATH=$prefix/bin${PATH:+:$PATH}
  export LD_LIBRARY_PATH=$prefix/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
  export CMAKE_PREFIX_PATH=$prefix${CMAKE_PREFIX_PATH:+:$CMAKE_PREFIX_PATH}
  echo "PATH = ${PATH}"
  echo "LD_LIBRARY_PATH = ${LD_LIBRARY_PATH}"
  echo "CMAKE_PREFIX_PATH = ${CMAKE_PREFIX_PATH}"
  echo "=========================="
}

function build_lib() {
  # Args: build_script_name
  set +x
  local var="STACK_${1}_build"
  set +u
  local stack_build=${!var}
  set -u
  if [[ ${stack_build} =~ [yYtT] ]]; then
      [[ -f $logdir/$1.log ]] && ( logDate=$(date -r $logdir/$1.log +%F_%H%M); mv -f $logdir/$1.log $logdir/$1.log.$logDate )
      ${HPC_STACK_ROOT}/libs/build_$1.sh 2>&1 | tee "$logdir/$1.log"
      local ret=${PIPESTATUS[0]}
      if [[ $ret > 0 ]]; then
          echo "BUILD FAIL!  Lib: $1 Error:$ret"
          [[ ${STACK_EXIT_ON_FAIL} =~ [yYtT] ]] && exit $ret
      fi
      echo "BUILD SUCCESS! Lib: $1"
  fi
  set -x
}

function build_nceplib() {
  # Args: lib name
  set +x
  local var="STACK_${1}_build"
  set +u
  local stack_build=${!var}
  set -u
  if [[ ${stack_build} =~ [yYtT] ]]; then
      [[ -f $logdir/$1.log ]] && ( logDate=$(date -r $logdir/$1.log +%F_%H%M); mv -f $logdir/$1.log $logdir/$1.log.$logDate )
      ${HPC_STACK_ROOT}/libs/build_nceplibs.sh "$1" 2>&1 | tee "$logdir/$1.log"
      local ret=${PIPESTATUS[0]}
      if [[ $ret > 0 ]]; then
          echo "BUILD FAIL!  NCEPlib: $1 Error:$ret"
          [[ ${STACK_EXIT_ON_FAIL} =~ [yYtT] ]] && exit $ret
      fi
      echo "BUILD SUCCESS! NCEPlib: $1"
  fi
  set -x
}

function parse_yaml {
  set +x
  local yamlprefix=$2
  local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
  sed -ne "s|^\($s\):|\1|" \
       -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
       -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
  awk -F$fs '{
     indent = length($1)/2;
     vname[indent] = $2;
     for (i in vname) {if (i > indent) {delete vname[i]}}
     if (length($3) > 0) {
        vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
        printf("export %s%s%s=\"%s\"\n", "'$yamlprefix'",vn, $2, $3);
     }
  }'
  set -x
}

export -f update_modules
export -f no_modules
export -f set_pkg_root
export -f set_no_modules_path
export -f build_lib
export -f build_nceplib
export -f parse_yaml
