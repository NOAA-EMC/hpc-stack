#!/bin/bash
# © Crown Copyright 2020 Met Office UK
# This software is licensed under the terms of the Apache Licence Version 2.0 which can be obtained at
# http://www.apache.org/licenses/LICENSE-2.0.

set -eux

name="json-schema-validator"
version=${1:-${STACK_json_schema_validator_version}}

if $MODULES; then
    set +x
    source $MODULESHOME/init/bash
    module load hpc-$HPC_COMPILER
    module try-load cmake
    module try-load json
    module list
    set -x

    prefix="${PREFIX:-"/opt/modules"}/core/$name/$version"
    if [[ -d $prefix ]]; then
        [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!"; $SUDO rm -rf $prefix ) \
                                   || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
    fi
else
    prefix=${JSON_SCHEMA_VALIDATOR_ROOT:-"/usr/local"}
fi

cd $HPC_STACK_ROOT/${PKGDIR:-"pkg"}

software="$name-$version"
gitURL="https://github.com/pboettch/json-schema-validator"
[[ -d $software ]] || ( git clone -b "$version" $gitURL $software )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

cmake .. \
      -DCMAKE_INSTALL_PREFIX=$prefix \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_POLICY_DEFAULT_CMP0074=NEW \
      -DBUILD_SHARED_LIBS=Y \
      -DBUILD_TESTS=$MAKE_CHECK \
      -DBUILD_EXAMPLES=N
[[ $MAKE_CHECK =~ [yYtT] ]] && make test
$SUDO make install

# generate modulefile from template
$MODULES && update_modules core $name $version \
         || echo $name $version >> ${HPC_STACK_ROOT}/hpc-stack-contents.log

exit 0
