#!/bin/bash                                                                                                                              

set -eux

name="met"
version=${1:-${STACK_met_version}}

# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')

