#!/bin/bash
set -eu

cron_dir=${HPC_DOWNLOAD_PATH}/hpc-stack/cron-ci

if [[ "$TEST_UFS" == true ]]; then

    cd ${HPC_DOWNLOAD_PATH}
    rm -rf ufs-weather-model

    ufs_logdate=$(date +'%Y-%m-%d-%R')
    ufs_logname=ufs_${ufs_logdate}.log
    ufs_log=${HPC_LOG_PATH}/${ufs_logname}

    git clone https://github.com/ufs-community/ufs-weather-model.git >> ${ufs_log} 2>&1
    cd ufs-weather-model

    ufs_hash=$(git rev-parse HEAD)

    echo ""
    echo "testing ufs-weather-model..."
    echo ""
    echo "UFS log: ${ufs_log}"
    echo "UFS hash: ${ufs_hash}"
    echo ""

    git submodule update --init --recursive >> ${ufs_log} 2>&1
    
    ${cron_dir}/test-ufs.sh >> ${ufs_log} 2>&1

    # check if ufs regression tests were successful
    if grep -qi "REGRESSION TEST WAS SUCCESSFUL" ${ufs_log}; then
        echo "UFS regression tests: PASS"
    else
        echo "UFS regression tests: FAIL"
    fi
fi

