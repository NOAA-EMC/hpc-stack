#!/bin/bash -l
set -eu

cron_dir=${HPC_DOWNLOAD_PATH}/hpc-stack/cron-ci

if [[ "$TEST_UFS" == true ]]; then
    # mm-dd-yyy-hh:mm
    ufs_logdate=$(date +'%m-%d-%Y-%R')
    ufs_logname=ufs_${ufs_logdate}.log
    ufs_log=${LOG_PATH}/${ufs_logname}
    
    echo ""
    echo "testing ufs-weather-model..."
    ${cron_dir}/test-ufs.sh >> ${ufs_log} 2>&1

    ufs-hash=$(git -C ${HPC_DOWNLOAD_PATH}/ufs-weather-model rev-parse HEAD)
    # check if ufs regression tests were successful
    if grep -qi "REGRESSION TEST WAS SUCCESSFUL" ${ufs_log}; then
        echo "UFS regression tests: PASS"
    else
        echo "UFS regression tests: FAIL"
    fi
    # Output data
    echo ""
    echo "ufs hash: ${ufs_hash}"
    echo "UFS log: ${ufs_log}"
fi

