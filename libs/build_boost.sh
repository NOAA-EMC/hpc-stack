#!/bin/bash

set -eux

name="boost"
version=${1:-${STACK_boost_version}}
level=${2:-${STACK_boost_level:-"full"}}

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

software=$name\_$(echo $version | sed 's/\./_/g')
URL="https://boostorg.jfrog.io/artifactory/main/release/$version/source/$software.tar.gz"

[[ -d $software ]] || $WGET $URL
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] || tar -xf $software.tar.gz
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )

########################################################################
# The headers-only option

if [[ $level = "headers-only" ]]; then

  $MODULES && prefix="${PREFIX:-"/opt/modules"}/core/$name/$version" \
           || prefix=${BOOST_ROOT:-"/usr/local"}
  $SUDO mkdir -p $prefix $prefix/include
  $SUDO cp -R boost $prefix/include

  # generate modulefile from template
  $MODULES && update_modules core "boost-headers" $version
  echo $name-headers $version $URL >> ${HPC_STACK_ROOT}/hpc-stack-contents.log

  exit 0
fi

########################################################################

# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')
mpi=$(echo $HPC_MPI | sed 's/\//-/g')

debug="--debug-configuration"

if $MODULES; then
  set +x
  source $MODULESHOME/init/bash
  module load hpc-$HPC_COMPILER
  [[ -z $mpi ]] || module load hpc-$HPC_MPI
  module list
  set -x
  prefix="${PREFIX:-"$HOME/opt"}/$compiler/$mpi/$name/$version"
  if [[ -d $prefix ]]; then
      if [[ $OVERWRITE =~ [yYtT] ]]; then
          echo "WARNING: $prefix EXISTS: OVERWRITING!"
          $SUDO rm -rf $prefix
      else
          echo "WARNING: $prefix EXISTS, SKIPPING"
          exit 0
      fi
  fi
else
  prefix=${BOOST_ROOT:-"/usr/local"}
fi

BoostRoot=$(pwd)
BoostBuild=$BoostRoot/BoostBuild
build_boost=$BoostRoot/build_boost
[[ -d $BoostBuild ]] && rm -rf $BoostBuild
[[ -d $build_boost ]] && rm -rf $build_boost

cd $BoostRoot/tools/build

# Configure with MPI
compName=$(echo $compiler | cut -d- -f1)
case "$compName" in
  gnu   ) MPICC=$(which mpicc)  ; toolset=gcc ;;
  intel ) MPICC=$(which mpiicc) ; toolset=intel ;;
  *     ) echo "Unknown compiler = $compName, ABORT!"; exit 1 ;;
esac

cp $BoostRoot/tools/build/example/user-config.jam ./user-config.jam
cat >> ./user-config.jam << EOF

# ------------------
# MPI configuration.
# ------------------
using mpi : $MPICC ;
EOF

rm -f $HOME/user-config.jam
[[ -z $mpi ]] && rm -f ./user-config.jam || mv -f ./user-config.jam $HOME

./bootstrap.sh --with-toolset=$toolset
./b2 install $debug --prefix=$BoostBuild

export PATH="$BoostBuild/bin:$PATH"

cd $BoostRoot
b2 $debug --build-dir=$build_boost address-model=64 toolset=$toolset stage
$SUDO mkdir -p $prefix $prefix/include
$SUDO cp -R boost $prefix/include
$SUDO mv stage/lib $prefix

rm -f $HOME/user-config.jam

# generate modulefile from template
[[ -z $mpi ]] && modpath=compiler || modpath=mpi
$MODULES && update_modules $modpath $name $version
echo $name $version $URL >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
