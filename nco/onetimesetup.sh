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






