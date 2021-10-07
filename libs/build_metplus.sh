#!/bin/bash                                                                                                                              

set -eux

name="METplus"
version=${1:-${STACK_metplus_version}}

cd  ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}
software="v"$version
pkg_name=$name-$version
met_version=${1:-${STACK_metplus_version}}
url="https://github.com/dtcenter/METplus/archive/$software.tar.gz"
[[ -d $software ]] || ( $WGET $url; tar -xf $software.tar.gz )
[[ -d $pkg_name ]] && cd $pkg_name || ( echo "$pkg_name does not exist, ABORT!"; exit 1 )


# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')
mpi=$(echo $HPC_MPI | sed 's/\//-/g')

if $MODULES; then
    prefix="${PREFIX:-"/opt/modules"}/$compiler/$name/$version"
    mkdir -p $prefix
    met_prefix="${PREFIX:-"/opt/modules"}/$compiler/$mpi"
else
    prefix=${MET_ROOT:-"/usr/local"}
    met_prefix=$prefix
fi

# Install is simply copying over the unpacked package to the install location
cp -r ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}/${pkg_name}/* $prefix
cd $prefix
curr_dir=$(pwd)
export PATH=${curr_dir}/ush:${PATH}


# Update the path to the MET tools for the users
cd ${curr_dir}/parm/metplus_config
cat metplus_system.conf | \
  sed "s%MET_INSTALL_DIR = /path/to%MET_INSTALL_DIR = $met_prefix/met/$met_version%g" \
  > metplus_system_new.conf
mv metplus_system_new.conf metplus_system.conf


# generate modulefile from template
[[ -z $mpi ]] && modpath=compiler || modpath=mpi
$MODULES && update_modules $modpath $name $version_install
echo $name $version_install $URL >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
