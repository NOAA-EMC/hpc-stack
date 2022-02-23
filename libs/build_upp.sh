#!/bin/bash

set -eux

name="upp"
URL="https://github.com/noaa-emc/upp"
version= ${STACK_upp_version}
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
  # post executable requires the following,
  # but we are not building post executable
  # module load sigio
  # module load sfcio
  # module load gfsio
  # module load nemsio
  module list
  set -x

  install_as=${3:-${s_install_as}} #  third column of COMPONENTS
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

if [[ -f "./CMakeLists.txt" ]]; then
    using_cmake=true
else
    using_cmake=false
fi

git checkout $version
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0

[[ -d build ]] && $SUDO rm -rf build
mkdir -p build && cd build

CMAKE_OPTS="-DBUILD_POSTEXEC=OFF ${STACK_upp_cmake_opts:-""}"

if [[ "$using_cmake" = true ]]; then
    cmake .. -DCMAKE_INSTALL_PREFIX=$prefix ${CMAKE_OPTS}
    VERBOSE=$MAKE_VERBOSE make -j${NTHREADS:-4}
    VERBOSE=$MAKE_VERBOSE $SUDO make install
else
    make -j4
fi

# generate modulefile from template
$MODULES && update_modules mpi $name $version
echo $name $version $URL >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
