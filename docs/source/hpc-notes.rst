.. This is a continuation of the hpc-install.rst chapter

.. _HPCNotes:

HPC-Stack Additional Notes
===========================

Setting compiler flags and other options
-----------------------------------------

Often it is necessary to specify compiler flags (e.g. ``gfortran-10
-fallow-argument-mismatch``) to the packages via ``FFLAGS``.  There are 2
ways this can be achieved.

1. For all packages: One can define variable e.g. ``STACK_FFLAGS=-fallow-argument-mismatch`` in the config file ``config_custom.sh``.  This will append ``STACK_FFLAGS`` to ``FFLAGS`` in every build script under libs.

2. Package specific flags: To compile only the specific package under ``libs`` with the above compiler flag, one can define variable ``FFLAGS=-fallow-argument-mismatch`` in the ``<package>`` section of the
YAML file ``stack_custom.yaml``. This will append ``STACK_<package>_FFLAGS`` to ``FFLAGS`` in the build script for that ``<package>`` only.

Adding a New Library or Package
--------------------------------

If you want to add a new library to the stack you need to follow these steps:

1. Write a new build script in libs, using exising scripts as a template

2. Define a new section in the ``yaml`` file for that library/package in config directory

3. If the package is a python virtual environment, add a ``requirements.txt`` or ``environment.yml`` file containing the listing the python packages required to install the package. These files should be named and placed in ``pyvenv/package_name.txt`` and ``pyvenv/package_name.yml``. ``VENVTYPE=pyvenv`` will use the ``pyvenv/package_name.txt`` and ``VENVTYPE=condaenv`` will use ``pyvenv/package_name.yml``

4. Add a call to the new build script in ``build_stack.sh``

5. Create a new module template at the appropriate place in the modulefiles directory, using exising files as a template

6. Update the `HPC Components <HPCComponents>` file to include the name of the new library or package

Configuring for a new HPC
---------------------------

If you want to port this to a new HPC, you need to follow these steps:

1. Write a new config file ``config/config_<hpc>.sh``, using existing configs as a template. Also create a new yaml file ``config/stack_<hpc>.yaml``, using existing yaml files as a template.

2. Add/remove basic modules for that HPC. 

3. Choose the appropriate Compiler/MPI combination.

4. If a template modulefile does not exist for that Compiler/MPI combinattion, create module templates at the appropriate place in the modulefiles directory, using existing files as a template. E.g. ``hpc-ips`` or ``hpc-smpi``.

5. If the HPC provides some basic modules for e.g. Git, CMake, etc. they can be loaded in ``config/config_<hpc>.sh``

Using the **DOWNLOAD_ONLY** Option
----------------------------------------

If an HPC (e.g., NOAA RDHPCS Hera) does not allow access to online software via ``wget`` or ``git clone``, you will have to download all the packages using the **DOWNLOAD_ONLY** option in the ``config_custom.sh``. Execute ``build_stack.sh`` as you would on a machine that does allow access to online software with ``DOWNLOAD_ONLY=YES`` and all the packages will be downloaded in the ``pkg`` directory.  Transfer the contents of the ``pkg`` directory to the machine you wish to install the hpc-stack and execute ``build_stack.sh``.  ``build_stack.sh`` will detect the already downloaded packages and use them rather than fetching them.

Using the HPC-stack
---------------------

* If Lmod is used to manage the software stack, to use the HPC-stack,
  you need to activate the stack.  This is done by loading the ``hpc``
  module under ``$PREFIX/modulefiles/stack`` as follows:

  .. code-block:: console

    module use $PREFIX/modulefiles/stack
    module load hpc/1.0.0

This will put the ``hpc-<compilerName>`` module in your ``MODULEPATH``,
which can be loaded as:

  .. code-block:: console

    module load hpc-<compilerName>/<compilerVersion>

* If the HPC-stack is not managed via modules, you need to add ``$PREFIX`` to the PATH as follows:

  .. code-block:: console
    
    export PATH="$PREFIX/bin:$PATH"
    export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
    export CMAKE_PREFIX_PATH="$PREFIX"

Known Workaround for Certain Installations of Lmod
----------------------------------------------------

* On some machine's (e.g., **WCOSS_DELL_P3**), LMod is built to disable loading of default modulefiles and requires the user to load the module with an explicit version of the module.  e.g. ``module load netcdf/4.7.4`` instead of ``module load netcdf``. The latter looks for the ``default`` module which is either the latest version or a version that is marked as default.  To circumvent this, it is necessary to place the following lines in ``modulefiles/stack/hpc/hpc.lua`` prior to executing ``setup_modules.sh`` or in ``$PREFIX/modulefiles/stack/hpc/1.0.0.lua`` after executing ``setup_modules.sh``.

  .. code-block:: console
  
    -- https://lmod.readthedocs.io/en/latest/090_configuring_lmod.html
    setenv("LMOD_EXACT_MATCH", "no")
    setenv("LMOD_EXTENDED_DEFAULT", "yes")


Known Issues
===============

* NetCDF-C++ does not build with LLVM Clang. It can be disabled by setting ``disable_cxx: YES`` in the stack file under the NetCDF section.

* Json-schema-validator does not build with LLVM Clang. It can be disabled in the stack file in the json-schema-validator-section.


Disclaimer
=============

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
