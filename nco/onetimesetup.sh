#!/bin/bash
set -eux
hpcstackdir=$(cd ../ && pwd)

# Remove dash in compiler/mpi name in module so that install tree is <compiler>/<version> instead of <compiler>-<version>
find $hpcstackdir/modulefiles -type f -name "*.lua" -exec sed -i "s:local compNameVerD .*::" {} \;
find $hpcstackdir/modulefiles -type f -name "*.lua" -exec sed -i "s:local mpiNameVerD .*::" {} \;

find $hpcstackdir/modulefiles -type f -name "*.lua" -exec sed -i "s:compNameVerD:compNameVer:" {} \;
find $hpcstackdir/modulefiles -type f -name "*.lua" -exec sed -i "s:mpiNameVerD:mpiNameVer:" {} \;

# Remove dash from build scripts
find $hpcstackdir/libs -type f -name "build_*.sh" -exec sed -i 's:compiler=$(.*:compiler=$(echo $HPC_COMPILER):' {} \;
find $hpcstackdir/libs -type f -name "build_*.sh" -exec sed -i 's:mpi=$(.*:mpi=$(echo $HPC_MPI):' {} \;

