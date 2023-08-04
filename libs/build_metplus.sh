#!/bin/bash                                                                                                                              

set -eux

name="metplus"
version=${1:-${STACK_metplus_version}}

# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')

cd  ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}
software="v"$version
pkg_name=METplus-$version
met_version=${1:-${STACK_met_version}}
URL="https://github.com/dtcenter/METplus/archive/$software.tar.gz"
[[ -d $software ]] || ( $WGET $URL; tar -xf $software.tar.gz )
[[ -d $pkg_name ]] && cd $pkg_name || ( echo "$pkg_name does not exist, ABORT!"; exit 1 )

if $MODULES; then
    prefix="${PREFIX:-"/opt/modules"}/$compiler/$name/$version" 
    met_prefix="${PREFIX:-"/opt/modules"}/$compiler"
else
    prefix=${MET_ROOT:-"/usr/local"}
    met_prefix=$prefix
fi

if [[ -d $prefix ]]; then
    if [[ $OVERWRITE =~ [yYtT] ]]; then
        echo "WARNING: $prefix EXISTS: OVERWRITING!"
        $SUDO rm -rf $prefix
    else
        echo "WARNING: $prefix EXISTS, SKIPPING"
        exit 0
    fi
fi

mkdir -p $prefix

# Install is simply copying over the unpacked package to the install location
cp -r ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}/${pkg_name}/* $prefix
cd $prefix
curr_dir=$(pwd)

# Update the path to the MET tools for the users
cd ${curr_dir}/parm/metplus_config
cat metplus_system.conf | \
  sed "s%MET_INSTALL_DIR = /path/to%MET_INSTALL_DIR = $met_prefix/met/$met_version%g" \
  > metplus_system_new.conf
mv metplus_system_new.conf metplus_system.conf


# generate modulefile from template
$MODULES && update_modules compiler $name $version
echo $name $version $URL >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
