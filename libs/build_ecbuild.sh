#!/bin/bash

set -eux

name="ecbuild"
repo=${1:-${STACK_ecbuild_repo:-"ecmwf"}}
version=${2:-${STACK_ecbuild_version:-"master"}}

if $MODULES; then
  set +x
  source $MODULESHOME/init/bash
  module try-load cmake
  module list
  set -x

  prefix="${PREFIX:-"/opt/modules"}/core/$name/$repo-$version"
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
  prefix=${ECBUILD_ROOT:-"/usr/local"}
fi

software=$name-$repo-$version
cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}
URL="https://github.com/$repo/$name.git"
[[ -d $software ]] || git clone $URL $software
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )

git checkout $version

# Conform to NCO IT FISMA High Standards
if [[ ${NCO_IT_CONFORMING:-"NO"} =~ [yYtT] ]]; then
  sed -r -i 's|ssh://[a-zA-Z0-9.@]*||g' cmake/compat/ecmwf_git.cmake
  sed -r -i 's|http[]://[a-zA-Z0-9@${}_./]*||g' cmake/compat/ecmwf_git.cmake
  sed -r -i 's|http[]://[a-zA-Z0-9./-]*/test-data|DISABLED_BY_DEFAULT|g' cmake/ecbuild_check_urls.cmake
  sed -r -i 's|http[]://[a-zA-Z0-9./-]*/test-data|DISABLED_BY_DEFAULT|g' cmake/ecbuild_get_test_data.cmake
fi

[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d build ]] && $SUDO rm -rf build
mkdir -p build && cd build

../bin/ecbuild --prefix=$prefix ..
VERBOSE=$MAKE_VERBOSE make -j${NTHREADS:-4}
VERBOSE=$MAKE_VERBOSE $SUDO make install

# generate modulefile from template
$MODULES && update_modules core $name $repo-$version
echo $name $version $URL >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
