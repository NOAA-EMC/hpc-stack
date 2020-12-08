
![Ubuntu](https://github.com/noaa-emc/hpc-stack/workflows/Build%20Ubuntu/badge.svg)
![macOS](https://github.com/noaa-emc/hpc-stack/workflows/Build%20macOS/badge.svg)

# hpc-stack

This repository provides a unified, shell script based build system
for building software stack needed for the NOAA [Universal Forecast
System (UFS)](https://github.com/ufs-community/ufs-weather-model) and
related products, and applications written for the [Joint Effort for
Data assimilation Integration
(JEDI)](https://jointcenterforsatellitedataassimilation-jedi-docs.readthedocs-hosted.com/en/latest/)
framework.

This is part of the [NCEPLIBS](https://github.com/NOAA-EMC/NCEPLIBS)
project.

## Authors

Rahul Mahajan, Kyle Gerheiser, Dusan Jovic, Hang-Lei, Dom Heinzeller

Code Manager: Kyle Gerheiser

Installers:

Machine | Programmer
------------|------------------
Orion | Hang-Lei
Hera | Kyle Gerheiser
Jet | Kyle Gerheiser
WCOSS-Dell | Hang-Lei
cheyenne | Dom Heinzeller
gaea | Dom Heinzeller
WCOSS-Cray | Hang-Lei

## Prerequisites:

The prerequisites of building hpc-stack are:

- [Lmod](https://lmod.readthedocs.io/en/latest/) - An Environment Module System
- CMake and make
- wget and curl
- git

Building the software stack is a **Three-Step process**, as described
in the following sections.

## Step 1: Configure Build

The first step is to choose the **COMPILER** and the **MPI** specify
any other aspects of the build that you would like.  This is normally
done by editing the file `config/config_custom.sh`.  Here we describe
some of the parameter settings available.

- **HPC_COMPILER:** This defines the vendor and version of the
    compiler you wish to use for this build.  The format is the same
    as what you would typically use in a module load command. For
    example, `HPC_COMPILER=intel/2020`.

- **HPC_MPI:** is the MPI library you wish to use for this build.  The
    format is the same as for `HPC_COMPILER`, for example:
    `HPC_MPI=impi/2020`.

- **USE_SUDO:** If `PREFIX` is set to a value that requires root
    permission to write to, such as `/opt/modules`, then this flag
    should be enabled. For example, `USE_SUDO=Y`

- **DOWNLOAD_ONLY:** The stack allows the option to download the
    source code for all the software without performing the
    installation.  This is especially useful for installing the stack
    on machines that do not allow internet connectivity to websites
    hosting the softwares e.g. GitHub.

- **NOTE: To enable a boolean flag use a single-digit `Y` or `T`.  To
    disable, use `N` or `F` (case insensitive)**_

- **PKGDIR:** is the directory where tarred or zipped software files
    will be downloaded and compiled.  Unlike `PREFIX`, this is a
    relative path, based on the root path of the repository.
    Individual software packages can be downloaded manually to this
    directory and untarred, but this is not required.  Build scripts
    will look for directory `pkg/pkgName-pkgVersion`
    e.g. `pkg/hdf5-1_10_3`.

- **LOGDIR:** is the directory where log files from the build will be
    written, relative to the root path of the repository.

- **OVERWRITE:** If set, this flag will cause the build script to
    remove the current installation, if any exists, and replace it
    with the new version of each software package in question.  If
    this is not set, the build will bypass software packages that are
    already installed.

- **NTHREADS:** The number of threads to use for parallel builds

- **MAKE_CHECK:** Run `make check` after build

- **MAKE_VERBOSE:** Print out extra information to the log files during the build

The next step is to choose what components of the stack you wish to
build.  This is done by editing the file `config/stack_custom.yaml`
which defines the software packages to be built along with their
version, options and compiler flags along with other package specific
options.

The following software can optionally be built with the scripts under
`libs`. These packages are built in Step 3 using the `build_stack.sh`
script.

* Compilers and MPI libraries
  - [GNU/GCC](https://gcc.gnu.org/)
  - Intel/IPS
  - [OpenMPI](https://www.open-mpi.org/)
  - [MPICH](https://www.mpich.org/)
  - `hpc-` Meta-modules for all the above as well as Intel and IMPI

* HPC Stack - Third Party Libraries
  - [CMake](https://cmake.org/)
  - [Udunits](https://www.unidata.ucar.edu/software/udunits/)
  - [PNG](http://www.libpng.org/pub/png/)
  - [JPEG](https://jpeg.org/)
  - [Jasper](https://github.com/jasper-software/jasper)
  - [SZip](https://support.hdfgroup.org/doc_resource/SZIP/)
  - [Zlib](http://www.zlib.net/)
  - [HDF5](https://www.hdfgroup.org/solutions/hdf5/)
  - [PNetCDF](https://parallel-netcdf.github.io/)
  - [NetCDF](https://www.unidata.ucar.edu/software/netcdf/)
  - [ParallelIO](https://github.com/NCAR/ParallelIO)
  - [nccmp](https://gitlab.com/remikz/nccmp)
  - [nco](http://nco.sourceforge.net/)
  - [CDO](https://code.mpimet.mpg.de/projects/cdo)
  - [FFTW](http://www.fftw.org/)
  - [GPTL](https://jmrosinski.github.io/GPTL/)
  - [Tau2]()
  - [Boost](https://beta.boost.org/)
  - [Eigen](http://eigen.tuxfamily.org/)
  - [JSON for C++](https://github.com/nlohmann/json/)
  - [JSON Schema Validator for C++](https://github.com/pboettch/json-schema-validator)

* UFS Dependencies
  - [ESMF](https://www.earthsystemcog.org/projects/esmf/)
  - [FMS](https://github.com/noaa-gfdl/fms.git)

* NCEP Libraries
  - [NCEPLIBS-bacio](https://github.com/noaa-emc/nceplibs-bacio.git)
  - [NCEPLIBS-sigio](https://github.com/noaa-emc/nceplibs-sigio.git)
  - [NCEPLIBS-sfcio](https://github.com/noaa-emc/nceplibs-sfcio.git)
  - [NCEPLIBS-gfsio](https://github.com/noaa-emc/nceplibs-gfsio.git)
  - [NCEPLIBS-w3nco](https://github.com/noaa-emc/nceplibs-w3nco.git)
  - [NCEPLIBS-sp](https://github.com/noaa-emc/nceplibs-sp.git)
  - [NCEPLIBS-ip](https://github.com/noaa-emc/nceplibs-ip.git)
  - [NCEPLIBS-ip2](https://github.com/noaa-emc/nceplibs-ip2.git)
  - [NCEPLIBS-g2](https://github.com/noaa-emc/nceplibs-g2.git)
  - [NCEPLIBS-g2c](https://github.com/noaa-emc/nceplibs-g2c.git)
  - [NCEPLIBS-g2tmpl](https://github.com/noaa-emc/nceplibs-g2tmpl.git)
  - [NCEPLIBS-nemsio](https://github.com/noaa-emc/nceplibs-nemsio.git)
  - [NCEPLIBS-nemsiogfs](https://github.com/noaa-emc/nceplibs-nemsiogfs.git)
  - [NCEPLIBS-w3emc](https://github.com/noaa-emc/nceplibs-w3emc.git)
  - [NCEPLIBS-landsfcutil](https://github.com/noaa-emc/nceplibs-landsfcutil.git)
  - [NCEPLIBS-bufr](https://github.com/noaa-emc/nceplibs-bufr.git)
  - [NCEPLIBS-wgrib2](https://github.com/noaa-emc/nceplibs-wgrib2.git)
  - [NCEPLIBS-prod_util](https://github.com/noaa-emc/nceplibs-prod_util.git)
  - [NCEPLIBS-grib_util](https://github.com/noaa-emc/nceplibs-grib_util.git)
  - [EMC_crtm](https://github.com/noaa-emc/EMC_crtm.git)
  - [EMC_post](https://github.com/noaa-emc/EMC_post.git)

* JEDI Dependencies
  - [ecbuild](https://github.com/jcsda/ecbuild.git)
  - [eckit](https://github.com/jcsda/eckit.git)
  - [fckit](https://github.com/jcsda/fckit.git)
  - [atlas](https://github.com/jcsda/atlas.git)

**IMPORTANT: Steps 1, 2, and 3 need to be repeated for each
  compiler/MPI combination that you wish to install.** The new
  packages will be installed alongside any previously-existing
  packages that may already have been built from other compiler/MPI
  combinations.

## Step 2: Set Up Compiler, MPI, and Module System

This step is only required if using LMod modules for managing the
software stack.  If LMod is not desired or used, the user can skip
ahead to Step 3.

Run from the top directory:
```
./setup_modules.sh -p <prefix> -c <configuration>
```
where:

- `<prefix>` is the directory where the software packages will be
  installed with a default value `$HOME/opt`.  The software
  installation trees (the top level of each being is the compiler,
  e.g. `intel-2020`) will branch directly off of `<prefix>` while the
  module files will be located in the `<prefix>/modulefiles`
  subdirectory.

- `<configuration>` points to the configuration script that you wish
  to use, as described in Step 1.  For example, to use the
  `config/config_custom.sh` you would enter this:

```
./setup_modules.sh -c config/config_custom.sh
```

If no arguments are specified, the default is
`config/config_custom.sh`.  Note that you can skip this step as well
for container builds because we currenly include only one compiler/mpi
combination in each container.  So, each package is only build once
and there is no need for modules.

This script sets up the module directory tree in
`<prefix>/modulefiles`.  It also sets up the compiler and mpi modules.
The compiler and mpi modules are handled separately from the rest of
the build because, when possible, we wish to exploit site-specific
installations that maximize performance.

**For this reason, the compiler and mpi modules are preceded by a
  `hpc-` label**.  For example, to load the Intel compiler module and
  the Intel MPI (IMPI) software library, you would enter this:

```
module load hpc-intel/2020
module load hpc-impi/2020
```

These `hpc-` modules are really meta-modules that will both load the
compiler/mpi library and modify the `MODULEPATH` so the user has
access to the software packages that will be built in Step 4.  On HPC
systems, these meta-modules will load the native modules provided by
the system administrators.  For example, `module load hpc-impi/2020`
will first load the native `impi/2020` module and then modify the
`MODULEPATH` accordingly to allow users to access the custom libraries
built by this repository.

So, in short, you should never load the compiler or MPI modules
directly.  Instead, you should always load the `hpc-` meta-modules as
demonstrated above - they will provide everything you need to load and
then use these software libraries.

If the compiler and/or MPI is natively available on the system and the
user wishes to make use of it e.g. `/usr/bin/gcc`, the
`setup_modules.sh` script prompts the user to answer questions
regarding their use.  For e.g. in containers, one would like to use
the system provided GNU compilers, but build a MPI implementation.

## Step 3: Build Software Stack

Now all that remains is to build the stack:

```
./build_stack.sh -p <prefix> -c <configuration> -y <yaml> -m
```

Here the `-m` option is only required if LMod is used for managing the
software stack.  It should be omitted otherwise.  `<prefix>` and
`<configuration>` are the same as in Step 2, namely a reference to the
installation prefix and a corresponding configuration file in the
`config` directory.  As in Step 2, if this argument is omitted, the
default is to use `$HOME/opt` and `config/config_custom.sh`
respectively.  `<yaml>` represents a user configurable yaml file
containing a list of packages that need to be built in the stack along
with their versions and package options. The default value of `<yaml>`
is `config/stack_custom.yaml`.

## Additional Notes:

### Setting compiler flags and other options

Often it is necessary to specify compiler flags (e.g. `gfortran-10
-fallow-argument-mismatch`) to the packages via `FFLAGS`.  There are 2
ways this can be achieved.

1. For all packages: One can define variable
e.g. `STACK_FFLAGS=-fallow-argument-mismatch` in the config file
`config_custom.sh`.  This will append `STACK_FFLAGS` to `FFLAGS` in
every build script under libs.

2. Package specific flags: To compile only the specific package under
`libs` with the above compiler flag, one can define variable
`FFLAGS=-fallow-argument-mismatch` in the `<package>` section of the
YAML file `stack_custom.yaml`.  This will append
`STACK_<package>_FFLAGS` to `FFLAGS` in the build script for that
`<package>` only.

### Adding a New library/package

If you want to add a new library to the stack you need to follow these
steps:

1. write a new build script in libs, using exising scripts as a
template

2. define a new section in the `yaml` file for that library/package in
config directory

3. Add a call to the new build script in `build_stack.sh`

4. Create a new module template at the appropriate place in the
modulefiles directory, using exising files as a template

### Configuring for a new HPC

If you want to port this to a new HPC, you need to follow these steps:

1. Write a new config file `config/config_<hpc>.sh`, using existing
configs as a template. Also create a new yaml file
`config/stack_<hpc>.yaml`, using existing yaml files as a template.

2. Add/remove basic modules for that HPC

3. Choose the appropriate Compiler/MPI combination.

4. If a template modulefile does not exist for that Compiler/MPI
combinattion, create module templates at the appropriate place in the
modulefiles directory, using existing files as a
template. E.g. `hpc-ips` or `hpc-smpi`.

5. If the HPC provides some basic modules for e.g. Git, CMake,
etc. they can be loaded in `config/config_<hpc>.sh`

### Using the **DOWNLOAD_ONLY** option

If an HPC (e.g. NOAA RDHPCS Hera) does not allow access to online
software via `wget` or `git clone`, you will have to download all the
packages using the **DOWNLOAD_ONLY** option in the `config_custom.sh`.
Execute `build_stack.sh` as you would on a machine that does allow
access to online software with `DOWNLOAD_ONLY=YES` and all the
packages will be downloaded in the `pkg` directory.  Transfer the
contents of the `pkg` directory to the machine you wish to install the
hpc-stack and execute `build_stack.sh`.  `build_stack.sh` will detect
the already downloaded packages and use them rather than fetching
them.

### Using the HPC-stack

- If Lmod is used to manage the software stack, to use the HPC-stack,
  you need to activate the stack.  This is done by loading the `hpc`
  module under `$PREFIX/modulefiles/stack` as follows:

```
module use $PREFIX/modulefiles/stack
module load hpc/1.0.0
```

This will put the `hpc-<compilerName>` module in your `MODULEPATH`,
which can be loaded as:

```
module load hpc-<compilerName>/<compilerVersion>
```

- If the HPC-stack is not managed via modules, you need to add
  `$PREFIX` to the PATH as follows:

```
export PATH="$PREFIX/bin:$PATH"
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
export CMAKE_PREFIX_PATH="$PREFIX"
```

### Known workaround for certain installations of Lmod.

- On some machine's (e.g. **WCOSS_DELL_P3**), LMod is built to disable
  loading of default modulefiles and requires the user to load the
  module with an explicit version of the module.  e.g. `module load
  netcdf/4.7.4` instead of `module load netcdf`. The latter looks for
  the `default` module which is either the latest version or a version
  that is marked as default.  To circumvent this, it is necessary to
  place the following lines in `modulefiles/stack/hpc/hpc.lua` prior
  to executing `setup_modules.sh` or in
  `$PREFIX/modulefiles/stack/hpc/1.0.0.lua` after executing
  `setup_modules.sh`.

```
-- https://lmod.readthedocs.io/en/latest/090_configuring_lmod.html
setenv("LMOD_EXACT_MATCH", "no")
setenv("LMOD_EXTENDED_DEFAULT", "yes")
```

## Known Issues

- ESMF beta snapshot 27 does not work on macOS. `stack_mac` installs
  beta 21 instead.

- NetCDF-C++ does not build with LLVM Clang. It can be disabled by setting
`disable_cxx: YES` in the stack file under the NetCDF section.

- Json-schema-validator does not build with LLVM Clang. It can be disabled
in the stack file in the json-schema-validator-section.

## Disclaimer

The United States Department of Commerce (DOC) GitHub project code is
provided on an "as is" basis and the user assumes responsibility for
its use. DOC has relinquished control of the information and no longer
has responsibility to protect the integrity, confidentiality, or
availability of the information. Any claims against the Department of
Commerce stemming from the use of its GitHub project will be governed
by all applicable Federal law. Any reference to specific commercial
products, processes, or services by service mark, trademark,
manufacturer, or otherwise, does not constitute or imply their
endorsement, recommendation or favoring by the Department of
Commerce. The Department of Commerce seal and logo, or the seal and
logo of a DOC bureau, shall not be used in any manner to imply
endorsement of any commercial product or activity by DOC or the United
States Government.
