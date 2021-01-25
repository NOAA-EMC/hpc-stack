#!/bin/bash
set -eux

# change module use to new hpc-stack location
sed -i "s:module use /.*/stack:module use ${HPC_INSTALL_PATH}/modulefiles/stack:" modulefiles/${HPC_MACHINE_ID}.${RT_COMPILER}/*

# remove versions from hpc-stack libraries only (between module load hpc and end-of-file)
sed -i "/module load hpc/,\$ s:module load \(.*\)/.*:module load \1:" modulefiles/${HPC_MACHINE_ID}.${RT_COMPILER}/*

# give version to ESMF because two versions are built
sed -i "s:module load esmf:module load esmf/${STACK_esmf_version}:" modulefiles/${HPC_MACHINE_ID}.${RT_COMPILER}/fv3

# check if fv3_debug exists. sed fails if it doesn't.
if [[ -f modulefiles/${HPC_MACHINE_ID}.${RT_COMPILER}/fv3_debug ]]; then
    sed -i "s:module load esmf:module load esmf/${STACK_esmf_version}-debug:" modulefiles/${HPC_MACHINE_ID}.${RT_COMPILER}/fv3_debug
fi

cd tests
./rt.sh ${UFS_RT_FLAGS}
