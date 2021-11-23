#!/bin/bash
# This script installs/updates hpc-stack packages.
# Four arguments:
#  -envir (prod/para/test)
#  -compiler ("all" uses all available compilers, listed below)
#  -package ("all" compiles all)
set -eux

hpcstackdir=$(cd ../ && pwd)
cd $hpcstackdir

envir=${1:?"envir? (first argument)"}
whichcompiler=${2:?"which compiler? (second argument)"}
whichpackage=${3:?"which package (stack/stack_<?>.yaml); 'all' compiles all? (third argument)"}
user=$(whoami)
installprefix=/apps/ops/${envir}/libs

if [ ${user/#ops./} != $envir ]; then
  read -p "User '$user' may not have permission to write to '${installprefix}'. You have been warned! ENTER to continue, Ctrl-C to quit."
fi

if [ $whichpackage == "all" ]; then
  yaml=stack_nco_wcoss2.yaml
  read -p "Are you sure you want to recompile all packages? ENTER to continue, Ctrl-C to quit."
else
  yaml=stack_${whichpackage}.yaml
fi
if [ ! -f stack/$yaml ]; then
  echo "yaml config file 'stack/$yaml' does not exist! Exitting..."
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

for configfile in config_nco_wcoss2.sh ; do
  ./build_stack.sh -p $installprefix -c config/$configfile -y stack/$yaml -m
  # Build two versions of wgrib2 for NCEP rotated lat-lon grid interpolation (ip) and WMO rot lat-lon grids (ip2)
  if [ $whichpackage == all ]; then ./build_stack.sh -p $installprefix -c config/$configfile -y stack/stack_wgrib2_2_0_7.yaml -m; fi
  if [ $whichpackage == all ]; then ./build_stack.sh -p $installprefix -c config/$configfile -y stack/stack_wgrib2_2_0_8.yaml -m ; fi
  if [ $whichpackage == all ]; then ./build_stack.sh -p $installprefix -c config/$configfile -y stack/stack_wgrib2_2_0_8_ip2.yaml -m ; fi

  # Build multiple versions of these libraries
  if [ $whichpackage == all ]; then ./build_stack.sh -p $installprefix -c config/$configfile -y stack/stack_g2_v3_4_1.yaml -m ; fi
  if [ $whichpackage == all ]; then ./build_stack.sh -p $installprefix -c config/$configfile -y stack/stack_g2_v3_4_4.yaml -m ; fi
  if [ $whichpackage == all ]; then ./build_stack.sh -p $installprefix -c config/$configfile -y stack/stack_g2c_v1_6_2.yaml -m; fi
  if [ $whichpackage == all ]; then ./build_stack.sh -p $installprefix -c config/$configfile -y stack/stack_g2tmpl_v1_9_1.yaml -m ; fi
  if [ $whichpackage == all ]; then ./build_stack.sh -p $installprefix -c config/$configfile -y stack/stack_w3emc_v2_9_1.yaml -m ; fi
  if [ $whichpackage == all ]; then ./build_stack.sh -p $installprefix -c config/$configfile -y stack/stack_w3emc_v2_9_2.yaml -m ; fi
done

cd $installprefix
find modulefiles/ \( -path '*hpc-cray-mpich*' -o -path '*hpc-intel*' \) -type f | xargs rm -f
find modulefiles/ \( -path '*hpc-cray-mpich*' -o -path '*hpc-intel*' \) -type d | xargs rm -rf
rm -rf modulefiles/core/hpc-python
rm -rf modulefiles/stack/hpc
