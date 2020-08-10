#!/bin/bash
# The purpose of this script is to build the software stack using
# the compiler/MPI combination defined by setup_modules.sh
#
# Arguments:
# configuration: Determines which libraries will be installed.
#     Each supported option will have an associated config_<option>.sh
#     file that will be used to
#
# sample usage:
# build_stack.sh "custom"

set -e

# currently supported configuration options
supported_options=("custom")

# root directory for the repository
HPC_BUILDSCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export HPC_STACK_ROOT=${HPC_BUILDSCRIPTS_DIR}

# ===============================================================================
# First source the config file

if [[ $# -ne 1 ]]; then
    source "${HPC_BUILDSCRIPTS_DIR}/config/config_custom.sh"
else
    config_file="${HPC_BUILDSCRIPTS_DIR}/config/config_$1.sh"
    if [[ -e $config_file ]]; then
      source $config_file
    else
      echo "ERROR: CONFIG FILE $config_file DOES NOT EXIST!"
      echo "Currently supported options: "
      echo ${supported_options[*]}
      exit 1
    fi

fi

HPC_OPT=${HPC_OPT:-$OPT}
if [ -z "$HPC_OPT" ]; then
    echo "Set HPC_OPT to modules directory (suggested: $HOME/opt/modules)"
    exit 1
fi

compilerName=$(echo $HPC_COMPILER | cut -d/ -f1)
compilerVersion=$(echo $HPC_COMPILER | cut -d/ -f2)

mpiName=$(echo $HPC_MPI | cut -d/ -f1)
mpiVersion=$(echo $HPC_MPI | cut -d/ -f2)

echo "Compiler: $compilerName/$compilerVersion"
echo "MPI: $mpiName/$mpiVersion"

# Source helper functions
source "${HPC_BUILDSCRIPTS_DIR}/stack_helpers.sh"

# this is needed to set environment variables if modules are not used
$MODULES || no_modules $1

# Parse config/stack_$1.yaml to determine software and version
eval $(parse_yaml config/stack_$1.yaml "STACK_")

# create build directory if needed
pkgdir=${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}
mkdir -p $pkgdir

# This is for the log files
logdir=$HPC_STACK_ROOT/$LOGDIR
mkdir -p $logdir

# install with root permissions?
[[ $USE_SUDO =~ [yYtT] ]] && export SUDO="sudo" || unset SUDO

# ===============================================================================

# start with a clean slate
if $MODULES; then
  module use $HPC_OPT/modulefiles/core
  module load hpc-stack
fi

# ===============================================================================
#----------------------
# MPI-independent
# - should add a check at some point to see if they are already there.
# this can be done in each script individually
# it might warrant a --force flag to force rebuild when desired
build_lib cmake   ${STACK_cmake_version}
build_lib udunits ${STACK_udunits_version}
build_lib jpeg    ${STACK_jpeg_version}
build_lib zlib    ${STACK_zlib_version}
build_lib png     ${STACK_png_version}
build_lib szip    ${STACK_szip_version}
build_lib jasper  ${STACK_jasper_version}

#----------------------
# MPI-dependent
# These must be rebuilt for each MPI implementation
build_lib hdf5    ${STACK_hdf5_version}
build_lib pnetcdf ${STACK_pnetcdf_version}
build_lib netcdf  ${STACK_netcdf_c_version} ${STACK_netcdf_f_version} ${STACK_netcdf_cxx_version}
build_lib nccmp   ${STACK_nccmp_version}
build_lib nco     ${STACK_nco_version}

build_lib pio  ${STACK_pio_version}
build_lib esmf ${STACK_esmf_version}

build_lib gptl ${STACK_gptl_version}
build_lib fftw ${STACK_fftw_version}
build_lib tau2 ${STACK_tau2_version}

# NCEPlibs
build_nceplib bacio ${STACK_bacio_version} ${STACK_bacio_install_as}
build_nceplib sigio ${STACK_sigio_version} ${STACK_sigio_install_as}
build_nceplib sfcio ${STACK_sfcio_version} ${STACK_sfcio_install_as}
build_nceplib gfsio ${STACK_gfsio_version} ${STACK_gfsio_install_as}
build_nceplib w3nco ${STACK_w3nco_version} ${STACK_w3nco_install_as}
build_nceplib sp    ${STACK_sp_version}    ${STACK_sp_install_as}
build_nceplib ip    ${STACK_ip_version}    ${STACK_ip_install_as}
build_nceplib ip2   ${STACK_ip2_version}   ${STACK_ip2_install_as}
build_nceplib landsfcutil ${STACK_landsfcutil_version} ${STACK_landsfcutil_install_as}
build_nceplib nemsio    ${STACK_nemsio_version}    ${STACK_nemsio_install_as}
build_nceplib nemsiogfs ${STACK_nemsiogfs_version} ${STACK_nemsiogfs_install_as}
build_nceplib w3emc     ${STACK_w3emc_version}     ${STACK_w3emc_install_as}
build_nceplib g2        ${STACK_g2_version}        ${STACK_g2_install_as}
build_nceplib g2tmpl    ${STACK_g2tmpl_version}    ${STACK_g2tmpl_install_as}
build_nceplib crtm      ${STACK_crtm_version}      ${STACK_crtm_install_as}
build_nceplib nceppost  ${STACK_nceppost_version}  ${STACK_nceppost_install_as}
build_nceplib wrf_io    ${STACK_wrf_io_version}    ${STACK_wrf_io_install_as}
build_nceplib bufr      ${STACK_bufr_version}      ${STACK_bufr_install_as}
build_nceplib wgrib2    ${STACK_wgrib2_version}    ${STACK_wgrib2_install_as}

# ===============================================================================
# optionally clean up
[[ $MAKE_CLEAN =~ [yYtT] ]] && \
    ( $SUDO rm -rf $pkgdir; $SUDO rm -rf $logdir )

# ===============================================================================
echo "build_stack.sh $1: success!"
