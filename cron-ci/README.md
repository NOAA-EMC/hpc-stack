## Cron CI

Provides a script that can be run using CRON on HPC systems to build
and test hpc-stack.

Set the variables in `setup_cron.sh` and then have cron run that
script. It will then checkout hpc-stack and build and test hpc-stack
using the ufs-weather-model regression tests.

To save resources, a hash of the last build, `prev_hash.txt` is saved
in `HPC_HOMEDIR` each time and if it doesn't change
between runs the script will exit.

## Variables

Set these variables in `setup-cron.sh`

* HPC_HOMEDIR - Path to store logs and save temporary data

* HPC_INSTALL_PATH - Path to install hpc-stack to

* HPC_DOWNLOAD_PATH - Path to download and build from

* HPC_CONFIG - Custom config so compiler/MPI and other options can be set

* HPC_STACK_FILE - The yaml file that specifies which libraries and versions to build. Default to config/stack_noaa.yaml

* LOG_PATH - The path to write logs to. Defaults to HPC_HOMEDIR/logs.

* HPC_MACHINE_ID - Name of machine (hera, orion, gaea, etc).
This is used to edit the correct modules in ufs-weather-model/machine.compiler 

* TEST_UFS - Run ufs-weather-model regression tests. Defaults to true.



