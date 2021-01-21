#!/bin/bash -l
set -eux

cd ${HPC_DOWNLOAD_PATH}
rm -rf ufs-weather-model

git clone https://github.com/ufs-community/ufs-weather-model.git
cd ufs-weather-model
git submodule update --init --recursive

# change module use to new hpc-stack location
sed -i "s:module use /.*/stack:module use ${HPC_INSTALL_PATH}/modulefiles/stack:" modulefiles/${HPC_MACHINE_ID}.intel/*

# remove version from module load
sed -i "s:module load \(.*\)/.*:module load \1:" modulefiles/${HPC_MACHINE_ID}.intel/*

# give version to ESMF because two versions are built
sed -i "s:module load esmf:module load esmf/${STACK_esmf_version}:" modulefiles/${HPC_MACHINE_ID}.intel/fv3
sed -i "s:module load esmf:module load esmf/${STACK_esmf_version}-debug:" modulefiles/${HPC_MACHINE_ID}.intel/fv3_debug

cd tests
./rt.sh -f -e


