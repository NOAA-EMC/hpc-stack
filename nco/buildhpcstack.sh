#!/bin/bash
# This script installs/updates hpc-stack packages.
# Four arguments:
#  -hpc-stack base dir (contains config/, libs/, modulefiles/, pkg/, etc.)
#  -envir (prod/para/test)
#  -compiler ("all" uses all available compilers, listed below)
#  -package ("all" compiles all)

#sed -i 's|export NCO_V=false|export NCO_V=true|' config/config_nco_wcoss2.sh

hpcstackdir=${1:?"hpc-stack dir?"}
cd $hpcstackdir
if [ $? -ne 0 ]; then
  echo "Directory '$hpcstackdir' could not be found."
  exit 1
fi
envir=${2:?"envir? (first argument)"}
whichcompiler=${3:?"which compiler? (second argument)"}
whichpackage=${4:?"which package (stack/stack_<?>.yaml); 'all' compiles all? (third argument)"}
user=$(whoami)
installprefix=/apps/ops/${envir}/libs

if [ ${user/#ops./} != $envir ]; then
  read -p "User '$user' may not have permission to write to '${installprefix}'. You have been warned! ENTER to continue, Ctrl-C to quit."
fi

if [ $whichpackage == "all" ]; then
  yaml=stack_nceplibs.yaml
  read -p "Are you sure you want to recompile all packages? ENTER to continue, Ctrl-C to quit."
else
  yaml=stack_${whichpackage}.yaml
fi
if [ ! -f config/$yaml ]; then
  echo "yaml config file 'config/$yaml' does not exist! Exitting..."
  exit 1
fi

case $whichcompiler in
  all) configfilelist="config_nco_wcoss2.sh" ;;
  intel) configfilelist="config_nco_wcoss2.sh" ;;
  gcc|gnu) echo "No gcc config file yet! Exitting..." ; exit 1 ;;
  *) echo "Compiler '$whichcompiler' not recognized! Exitting..." ; exit 1 ;;
esac

echo "Confirm installation:"
echo "  install prefix: $installprefix"
echo "  config script list: $(readlink -f config/$configfilelist)"
echo "  yaml config file: $(readlink -f stack/$yaml)"
read -p "ENTER to continue, Ctrl-C to quit."

./setup_modules.sh -p $installprefix -c config/config_nco_wcoss2.sh

for configfile in config_wcoss2.sh ; do
  ./build_stack.sh -p $installprefix -c config/$configfile -y config/$yaml -m
done

cd $installprefix
find modulefiles/ \( -path '*hpc-cray-mpich*' -o -path '*hpc-intel*' \) -type f | xargs rm -f
find modulefiles/ \( -path '*hpc-cray-mpich*' -o -path '*hpc-intel*' \) -type d | xargs rm -rf
rm -rf modulefiles/stack/hpc
