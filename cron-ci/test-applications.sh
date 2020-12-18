#!/bin/bash -l
set -eu

cron_dir=${HPC_DOWNLOAD_PATH}/hpc-stack/cron-ci

if [[ "$TEST_UFS" == true ]]; then
    
    ${cron_dir}/test-ufs.sh

    # check if ufs regression tests were successful
    if grep -qi "REGRESSION TEST WAS SUCCESSFUL" ${ufs_log}; then
        echo "UFS regression tests: PASS"
    else
        echo "UFS regression tests: FAIL"
    fi
fi

