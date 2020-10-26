#!/bin/bash

set -eux

name="jasper"
version=${1:-${STACK_jasper_version}}

# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')

[[ ${STACK_jasper_shared:-} =~ [yYtT] ]] && enable_shared=YES || enable_shared=NO

if $MODULES; then
  set +x
  source $MODULESHOME/init/bash
  module load hpc-$HPC_COMPILER
  # Load jpeg module if created by hpc-stack; requires setting
  # MAKE_POLICY_DEFAULT_CMP0074 to new below so that JPEG_ROOT is searched
  module try-load jpeg
  module list
  set -x
  prefix="${PREFIX:-"/opt/modules"}/$compiler/$name/$version"
  if [[ -d $prefix ]]; then
      [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix ) \
                                 || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
  fi
else
    prefix=${JASPER_ROOT:-"/usr/local"}
fi

export FC=$SERIAL_FC
export CC=$SERIAL_CC
export CXX=$SERIAL_CXX

export F77=$FC
export FFLAGS="${STACK_FFLAGS:-} ${STACK_jasper_FFLAGS:-} -fPIC"
export CFLAGS="${STACK_CFLAGS:-} ${STACK_jasper_CFLAGS:-} -fPIC"

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

software=$name-$version
#gitURL="https://github.com/mdadams/jasper"
gitURL="https://github.com/jasper-software/jasper"
[[ -d $software ]] || ( git clone -b "version-$version" $gitURL $software )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
sourceDir=$PWD
[[ -d build_jasper ]] && rm -rf build_jasper
mkdir -p build_jasper && cd build_jasper
buildDir=$PWD

[[ $enable_shared =~ [yYtT] ]] && shared_flags="" || shared_flags="-DJAS_ENABLE_SHARED=OFF"

# Starting w/ version-2.0.0, jasper is built using cmake
cmakeVer="2.0.0"
if [ "$(printf '%s\n' "$cmakeVer" "$version" | sort -V | head -n1)" = "$cmakeVer" ]; then
    useCmake=YES
else
    useCmake=NO
fi

if [[ "$useCmake" == "YES" ]]; then
    cd $sourceDir
    cmake -G "Unix Makefiles" \
      -H$sourceDir -B$buildDir \
      -DCMAKE_INSTALL_PREFIX=$prefix \
      -DCMAKE_BUILD_TYPE=RELEASE \
      -DJAS_ENABLE_DOC=FALSE \
      -DCMAKE_POLICY_DEFAULT_CMP0074=NEW \
      $shared_flags
    cd $buildDir
else
    ../configure --prefix=$prefix --enable-libjpeg
fi

make -j${NTHREADS:-4}
[[ $MAKE_CHECK =~ [yYtT] ]] && make check
$SUDO make install

# generate modulefile from template
$MODULES && update_modules compiler $name $version \
         || echo $name $version >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
