#!/bin/bash
set -eux

# change module use to new hpc-stack location
sed -i "s:module use /.*/stack:module use ${HPC_INSTALL_PATH}/modulefiles/stack:" modulefiles/ufs_${HPC_MACHINE_ID}.${RT_COMPILER}*

# remove versions from hpc-stack libraries
sed -i "s:module load \(.*\)/.*:module load \1:" modulefiles/ufs_common*

# give version to ESMF because two versions are built
sed -i "s:module load esmf:module load esmf/${STACK_esmf_version}:" modulefiles/ufs_common
sed -i "s:module load esmf:module load esmf/${STACK_esmf_version}-debug:" modulefiles/ufs_common_debug

cd tests
./rt.sh ${UFS_RT_FLAGS}
