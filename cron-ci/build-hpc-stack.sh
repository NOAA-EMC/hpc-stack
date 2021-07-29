#!/bin/bash

set -eux

rm -rf ${HPC_INSTALL_PATH}/*

# Don't build these libs because NOAA RDHPCS systems can't use wget or connect to gitlab
# finds the name of the library and changes the next line to "build: NO"
sed -i '/^udunits/{n;s/.*/  build: NO/}' ${HPC_STACK_FILE}
sed -i '/^szip/{n;s/.*/  build: NO/}' ${HPC_STACK_FILE}
sed -i '/^nccmp/{n;s/.*/  build: NO/}' ${HPC_STACK_FILE}
sed -i '/^cdo/{n;s/.*/  build: NO/}' ${HPC_STACK_FILE}
sed -i '/^boost/{n;s/.*/  build: NO/}' ${HPC_STACK_FILE}
sed -i '/^eigen/{n;s/.*/  build: NO/}' ${HPC_STACK_FILE}

# pass no to setup_modules when asked for native compiler/mpi. Using modules.
yes no | ./setup_modules.sh -c ${HPC_CONFIG} -p ${HPC_INSTALL_PATH}

./build_stack.sh -c ${HPC_CONFIG} -p ${HPC_INSTALL_PATH} -y ${HPC_STACK_FILE} -m

# Edit stack file to build debug version of ESMF
# Turn everything to build: NO, then enable just ESMF, then set debug: YES
sed -i 's/build: YES/build: NO/' ${HPC_STACK_FILE}
sed -i '/^esmf/{n;s/.*/  build: YES/}' ${HPC_STACK_FILE}
sed -i 's/debug: NO/debug: YES/' ${HPC_STACK_FILE}

# Build debug version of ESMF
./build_stack.sh -c ${HPC_CONFIG} -p ${HPC_INSTALL_PATH} -y ${HPC_STACK_FILE} -m



