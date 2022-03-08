#!/bin/bash
set -eux

name="upp"
URL="https://github.com/NOAA-EMC/UPP.git"
version=${STACK_upp_version}
openmp=${STACK_upp_openmp}
install_as=${STACK_upp_install_as:-${version}}

# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')
mpi=$(echo $HPC_MPI | sed 's/\//-/g')

if $MODULES; then
  set +x
  source $MODULESHOME/init/bash
  module load hpc-$HPC_COMPILER
  module load hpc-$HPC_MPI
  module try-load cmake
  module try-load libpng
  module try-load jasper
  module load netcdf
  module load bacio
  module load w3nco
  module load g2
  module load g2tmpl
  module load ip
  module load sp
  module load w3emc
  module load crtm
  module list
  set -x

  prefix="${PREFIX:-"/opt/modules"}/$compiler/$mpi/$name/$install_as"
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
  prefix=${UPP_ROOT:-"/usr/local"}
fi

export FC=$MPI_FC
export CC=$MPI_CC

software=$name-$version
cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}
[[ -d $software ]] || git clone $URL $software
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )

git checkout $version

if [[ -f CMakeLists.txt ]]; then
    using_cmake=true
else
    using_cmake=false
fi

[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0

if [[ "$using_cmake" = true ]]; then

    git submodule update --init --recursive
    [[ -d build ]] && $SUDO rm -rf build
    mkdir -p build && cd build

    CMAKE_OPTS="-DBUILD_POSTEXEC=OFF -DOPENMP=${openmp} ${STACK_upp_cmake_opts:-""}"
    
    cmake .. -DCMAKE_INSTALL_PREFIX=$prefix ${CMAKE_OPTS}
    VERBOSE=$MAKE_VERBOSE make -j${NTHREADS:-4}
    VERBOSE=$MAKE_VERBOSE $SUDO make install
else
    cd sorc/ncep_post.fd
    sed -i'.backup' "s:libupp_4.a:libupp.a:" makefile_lib
    sed -i'.backup' "s:include/upp_4:include:" makefile_lib

    export myFC=${FC}
    export myCPP=`which cpp`

    # Clean
    rm -rf include lib *.mod
    make -f makefile_lib clean

    # Build
    mkdir include lib
    make -f makefile_lib

    # Install
    mv libupp.a lib/
    mkdir -p $prefix
    cp -r include lib ${prefix}/
fi

# generate modulefile from template
$MODULES && update_modules mpi $name $install_as
echo $name $install_as $URL >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
