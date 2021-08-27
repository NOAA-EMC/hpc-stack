#!/bin/bash

tarfile=${1:-hpc-stack.tar}

if [ ! -e $tarfile ]; then
  echo "'$tarfile' not found! Quitting..."
  exit
fi

basedir=$(tar tf $tarfile | head -1)

tar xf $tarfile

HPC_STACK_ROOTDIR=$(realpath $basedir)

echo "hpc-stack package dir: $HPC_STACK_ROOTDIR"
read -p "ENTER to continue, ctrl-c to quit"

### NCO customizations:

# Change fallback dir in all modules from /opt/modules to /apps/ops/prod/libs:
find $HPC_STACK_ROOTDIR -type f -name '*.lua' | xargs sed -i 's|/opt/modules|/apps/ops/prod/libs|'

# Disable prod_util:
perl -i -0777 -pe 's|(?<=prod_util:\n)(\ +)build: YES|\1build: NO|' $HPC_STACK_ROOTDIR/config/stack_wcoss2.yaml

# Modify config/config_wcoss2.sh so it loads all necessary modules (since we're not using EMC's versions of NetCDF, HDF5, etc.):
sed -i 's|load lmod/cpe-intel|load PrgEnv-intel/8.1.0|;s|cray-mpich/8.1.2|cray-mpich/8.1.5|;s|source.*startLmod||' $HPC_STACK_ROOTDIR/config/config_wcoss2.sh
echo -e "\n\nmodule load hdf5/1.10.6\nexport HDF5_ROOT=\$HDF5_DIR\nmodule load netcdf/4.7.4\nexport NETCDF_ROOT=\$NETCDF_DIR\nmodule load jasper/2.0.25\nmodule load libjpeg/9c\nmodule load libpng/1.6.37" >> $HPC_STACK_ROOTDIR/config/config_wcoss2.sh

# Enable esmf:
echo -e "\nesmf:\n  build: YES\n  version: 8_1_0_beta_snapshot_27\n  shared: NO\n  enable_pnetcdf: NO\n  debug: NO" >> $HPC_STACK_ROOTDIR/config/stack_nceplibs.yaml

# Add $WGRIB2 variable to wgrib2 module file:
echo 'setenv("WGRIB2", pathJoin(base,"bin/wgrib2"))' >> $HPC_STACK_ROOTDIR/modulefiles/mpi/compilerName/compilerVersion/mpiName/mpiVersion/wgrib2/wgrib2.lua
sed -i 's|prereq("netcdf")|prereq("netcdf")\nload("libjpeg")\nprereq("libjpeg")\n|' $HPC_STACK_ROOTDIR/modulefiles/mpi/compilerName/compilerVersion/mpiName/mpiVersion/wgrib2/wgrib2.lua

# Add variables for executables for nemsio module:
echo -e 'setenv("MKGFSNEMSIOCTL",pathJoin(base,"bin/mkgfsnemsioctl"))\nsetenv("NEMSIO_CHGDATE",pathJoin(base,"bin/nemsio_chgdate"))\nsetenv("NEMSIO_GET",pathJoin(base,"bin/nemsio_get"))\nsetenv("NEMSIO_READ",pathJoin(base,"bin/nemsio_read"))' >> $HPC_STACK_ROOT\
DIR/modulefiles/mpi/compilerName/compilerVersion/mpiName/mpiVersion/nemsio/nemsio.lua
