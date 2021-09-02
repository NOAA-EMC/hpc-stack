#!/bin/bash
hpcstackdir=$(cd ../ && pwd)
find $hpcstackdir/modulefiles -type f -name "*.lua" -exec sed -i "s:local compNameVerD = .*::" {} \;
find $hpcstackdir/modulefiles -type f -name "*.lua" -exec sed -i "s:local mpiNameVerD = .*::" {} \;

find $hpcstackdir/libs -type f -name "build_*.sh" -exec sed -i "s:compiler=.*:compiler=$(echo $HPC_COMPILER):" {} \;
find $hpcstackdir/libs -type f -name "build_*.sh" -exec sed -i "s:compiler=.*:compiler=$(echo $HPC_MPI):" {} \;

