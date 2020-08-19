#!/bin/bash

function update_modules {
    PREFIX=${PREFIX:-${OPT}}
    case $1 in
        core )
            tmpl_file=$HPC_STACK_ROOT/modulefiles/core/$2/$2.lua
            to_dir=$PREFIX/modulefiles/core ;;
        compiler )
            tmpl_file=$HPC_STACK_ROOT/modulefiles/compiler/compilerName/compilerVersion/$2/$2.lua
            to_dir=$PREFIX/modulefiles/compiler/$HPC_COMPILER ;;
        mpi )
            tmpl_file=$HPC_STACK_ROOT/modulefiles/mpi/compilerName/compilerVersion/mpiName/mpiVersion/$2/$2.lua
            to_dir=$PREFIX/modulefiles/mpi/$HPC_COMPILER/$HPC_MPI ;;
        * ) echo "ERROR: INVALID MODULE PATH, ABORT!"; exit 1 ;;
    esac

    [[ -e $tmpl_file ]] || ( echo "ERROR: $tmpl_file NOT FOUND!  ABORT!"; exit 1 )

    [[ -d $to_dir ]] || ( echo "ERROR: $mod_dir MODULE DIRECTORY NOT FOUND!  ABORT!"; exit 1 )

    cd $to_dir
    $SUDO mkdir -p $2; cd $2
    $SUDO cp $tmpl_file $3.lua

    # Make the latest installed version the default
    [[ -e default ]] && $SUDO rm -f default
    $SUDO ln -s $3.lua default

}

function no_modules {

    # this function defines environment variables that are
    # normally done by the modules.
    # It's mainly intended for use when not using LMod

    compilerName=$(echo $HPC_COMPILER | cut -d/ -f1)
    mpiName=$(echo $HPC_MPI | cut -d/ -f1)

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
      * ) echo "Unknown compiler option = $compilerName, ABORT!"; exit 1 ;;
    esac

    case $mpiName in
      openmpi)
          export MPI_CC=${MPI_CC:-"mpicc"}
          export MPI_CXX=${MPI_CXX:-"mpicxx"}
          export MPI_FC=${MPI_FC:-"mpifort"}
          ;;
      mpich )
          export MPI_CC=${MPI_CC:-"mpicc"}
          export MPI_CXX=${MPI_CXX:-"mpicxx"}
          export MPI_FC=${MPI_FC:-"mpifort"}
          ;;
      impi )
          export MPI_CC=${MPI_CC:-"mpiicc"}
          export MPI_CXX=${MPI_CXX:-"mpiicpc"}
          export MPI_FC=${MPI_FC:-"mpiifort"}
          ;;
      * ) echo "Unknown MPI option = $mpiName, ABORT!"; exit 1 ;;
    esac

}

function set_pkg_root() {
  # export <PKG>_ROOT environment variables
  for i in $(printenv | grep "STACK_.*_build="); do
    pkg=$(echo $i | cut -d= -f1 | tr 'a-z' 'A-Z' | cut -d_ -f2- | rev | cut -d_ -f2- | rev)
    build=$(echo $i | cut -d= -f2)
    if [[ $build =~ ^(yes|YES|true|TRUE)$ ]]; then
        eval export ${pkg}_ROOT=${PREFIX:-"/usr/local"}
    fi
  done
}

function build_lib() {
    # Args: build_script_name
    set +x
    var="STACK_${1}_build"
    set +u
    stack_build=${!var}
    set -u
    if [[ ${stack_build} =~ [yYtT] ]]; then
        ${HPC_BUILDSCRIPTS_DIR}/libs/build_$1.sh 2>&1 | tee "$logdir/$1.log"
        ret=${PIPESTATUS[0]}
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
    var="STACK_${1}_build"
    if [[ ${!var} =~ [yYtT] ]]; then
        ${HPC_BUILDSCRIPTS_DIR}/libs/build_nceplibs.sh "$1" 2>&1 | tee "$logdir/$1.log"
        ret=${PIPESTATUS[0]}
        if [[ $ret > 0 ]]; then
            echo "BUILD FAIL!  NCEPlib: $1 Error:$ret"
            [[ ${STACK_EXIT_ON_FAIL} =~ [yYtT] ]] && exit $ret
        fi
        echo "BUILD SUCCESS! NCEPlib: $1"
    fi
    set -x
}

# Inspiration from:
# https://stackoverflow.com/questions/5014632/how-can-i-parse-a-yaml-file-from-a-linux-shell-script
function parse_yaml {
  set +x
  local prefix=$2
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
        printf("export %s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
     }
  }'
  set -x
}

export -f update_modules
export -f no_modules
export -f set_pkg_root
export -f build_lib
export -f build_nceplib
export -f parse_yaml
