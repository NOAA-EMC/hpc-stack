#!/bin/bash -l
# pass -l (treat script as login shell) so lmod module environment is picked up

# Set variables below and have cron run this script to download, build, and test hpc-stack
set -eu

# store logs and save previous hash here
export HPC_HOMEDIR=~/.hpc-stack
# path to install hpc-stack
export HPC_INSTALL_PATH=
# path to download hpc-stack and other components
export HPC_DOWNLOAD_PATH=

# hpc-stack config file to build with (set compiler and other options)
# I put these in the HPC_HOMEDIR
export HPC_CONFIG=${HPC_HOMEDIR}/
# hpc-stack yaml file to build with, use stack_noaa by default
export HPC_STACK_FILE=config/stack_noaa.yaml

# set machine name (hera, jet, orion, etc) so script edits correct ufs modulefiles
export HPC_MACHINE_ID=
export LOG_PATH=${HPC_HOMEDIR}/logs

# Run ufs-weather-model regression tests?
export TEST_UFS=true

# Create directories
mkdir -p ${HPC_DOWNLOAD_PATH}
mkdir -p ${HPC_HOMEDIR}
mkdir -p ${LOG_PATH}

cd $HPC_DOWNLOAD_PATH
rm -rf hpc-stack

# mm-dd-yyy-hh:mm
hpc_logdate=$(date +'%m-%d-%Y-%R')
hpc_logname=hpc-stack_${hpc_logdate}.log
hpc_log=${LOG_PATH}/${hpc_logname}

git clone https://github.com/NOAA-EMC/hpc-stack.git > /dev/null 2>&1
cd hpc-stack

# Parse hpc-stack yaml file to get version variables
source stack_helpers.sh
eval $(parse_yaml ${HPC_STACK_FILE} "STACK_")

# get the current hpc-stack hash and compare it to the previously built hash (if it exists)
# if it exists and matches current hash, don't build
current_hash=$(git rev-parse HEAD)

if [[ -f "${HPC_HOMEDIR}/prev_hash.txt" ]]; then
    prev_hash=$(cat ${HPC_HOMEDIR}/prev_hash.txt)
    if [[ "$current_hash" == "$prev_hash" ]]; then
        echo `date`
        echo ""
        echo "hpc-stack version has not changed since last time. Not building."
        echo "hpc-stack hash: ${current_hash}"
        exit 0
    fi
fi

echo `date`
echo ""
echo "building hpc-stack..."
./cron-ci/build-hpc-stack.sh >> ${hpc_log} 2>&1

# check if hpc-stack build succeded 
if grep -qi "build_stack.sh: SUCCESS!" ${hpc_log}; then
    echo "hpc-stack build: PASS"
    echo "hpc-stack hash: ${current_hash}"
    echo "hpc-stack log: ${hpc_log}"
    echo ""
else
    echo "hpc-stack build: FAIL"
    echo "hpc-stack hash: ${current_hash}"
    echo "hpc-stack log: ${hpc_log}"
    echo ""
    exit 1
fi

# save the current hash as the previous hash to compare to next time
echo $current_hash > $HPC_HOMEDIR/prev_hash.txt

./cron-ci/test-applications.sh
