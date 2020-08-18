#!/bin/bash

# This Build Lmod
# As written here, it requires root permission but this could be
# changed if needed.
#
# usage:
# build_lmod.sh <prefix>

set -eux

if [[ $# -lt 1 ]]; then
    mods_path=/opt
else
    mods_path=$1
fi

# For now hardwire these in - we could put this in the command line
# if there is any reason to
lua_version="5.1.4.9"
lmod_version="8.0"

#=================================================================================

# install lua
# If this doesn't work you can try a package install with:
# sudo apt-get install luarocks
#sudo luarocks install luaposix
#sudo luarocks install luafilesystem

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}
$WGET https://sourceforge.net/projects/lmod/files/lua-$lua_version.tar.bz2
bzip2 -d lua-$lua_version.tar.bz2; tar xvf lua-$lua_version.tar
cd lua-$lua_version
[[ -d build ]] && rm -rf build
mkdir -p build && cd build
../configure --prefix=$mods_path/lua/$lua_version
make
sudo make install
cd $mods_path/lua
sudo ln -s $lua_version lua
sudo ln -s $mods_path/lua/$lua_version/bin/* /usr/local/bin

# install lmod
# this installs in $MODULESHOME, which is set to $mods_path/lmod/lmod
cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}
$WGET https://sourceforge.net/projects/lmod/files/Lmod-$lmod_version.tar.bz2
bzip2 -d Lmod-$lmod_version.tar.bz2; tar xvf Lmod-$lmod_version.tar
cd Lmod-$lmod_version
[[ -d build ]] && rm -rf build
mkdir -p build && cd build
../configure --prefix=$mods_path
sudo make install

