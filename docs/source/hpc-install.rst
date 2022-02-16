.. _InstallBuildHPCstack:

================================
Install and Build the HPC-Stack
================================

.. warning::
   The HPC-stack is already installed on `Level 1 systems <https://github.com/ufs-community/ufs-srweather-app/wiki/Supported-Platforms-and-Compilers>`_ (e.g., Cheyenne, Hera, Orion). Installation is not necessary. 

HPC-Stack installation will vary from system to system because there are so many possible combinations of operating systems, compilers, MPI's, and package versions. Installation via an EPIC-provided container is recommended to reduce this variability. However, users may choose a non-container approach to installation if they prefer. 


.. _SingularityInstall:

Install and Build the HPC-Stack in a Singularity Container
===========================================================

The Earth Prediction Innovation Center (EPIC) provides several containers available for the installation of the stack and Unified Forecast System (UFS) applications: 

* docker://noaaepic/ubuntu20.04-gnu9.3
* docker://noaaepic/ubuntu20.04-hpc-stack
* docker://noaaepic/ubuntu20.04-epic-srwapp
* docker://noaaepic/ubuntu20.04-epic-mrwapp

Install Singularity
-----------------------

To install the HPC-stack via Singularity container, first install the Singularity package according to the `Singularity Installation Guide <https://sylabs.io/guides/3.2/user-guide/installation.html#>`_. This will include the installation of dependencies and the installation of the Go programming 
language. SingularityCE Version 3.7 or above is recommended. 

.. warning:: 
   Docker containers can only be run with root privileges, and users cannot have root privileges on HPC computers. Therefore, it is not possible to build the HPC-stack inside a Docker container. A Docker image may be pulled, but it must be run inside a container such as Singularity. 


Build and Run the Container
----------------------------

1. Pull and build the container.

   .. code-block:: console

      singularity pull ubuntu20.04-epic.sif docker://noaaepic/ubuntu20.04-epic
      singularity build --sandbox ubuntu20.04-epic ubuntu20.04-epic.sif
      cd ubuntu20.04-epic
   
   Make a directory (e.g. ``contrib``) in the container if one does not exist: 
      
      .. code-block:: console
         
         mkdir contrib
         cd ..

2. Start the container and run an interactive shell within it. This command also binds the local working 
directory to the container so that data can be shared between them.

   .. code-block:: console
      
      singularity shell -e --writable --bind /contrib:/contrib ubuntu20.04-gnu9.3


Build the HPC-Stack
--------------------

1. Clone the hpc-stack repository (from inside the singularity shell above).

   .. code-block:: console
      
      git clone -b feature/ubuntu20.04 https://github.com/jkbk2004/hpc-stack
      cd hpc-stack

2. Set up the build environment. Be sure to change the ``prefix`` argument in the code below to 
your system's install location (likely within the hpc-stack directory). 

   .. code-block:: console
   
      ./setup_modules.sh -p <prefix> -c config/config_custom.sh

   where <prefix> is the directory where the software packages will be installed with a default value $HOME/opt. 

   Enter YES/YES/YES when the option is presented. Then modify ``build_stack.sh`` with the following commands:
   
   .. code-block:: console
   
      sed -i "10 a source /usr/share/lmod/6.6/init/bash" ./build_stack.sh
      sed -i "10 a export PATH=/usr/local/sbin:/usr/local/bin:$PATH" ./build_stack.sh
      sed -i "10 a export LD_LIBRARY_PATH=/usr/local/lib64:/usr/local/lib:$LD_LIBRARY_PATH" ./build_stack.sh

3. Build the environment. This may take several hours to complete. 

   .. code-block:: console

      ./build_stack.sh -p <prefix> -c config/config_custom.sh -y stack/stack_custom.yaml -m

4. Load the required modules. 

   .. code-block:: console

      source /usr/share/lmod/lmod/init/bash
      module use <prefix>/modulefiles/stack
      module load hpc hpc-gnu hpc-openmpi
      module avail

From here, the user can continue to install and run applications that depend on the HPC-Stack, such as the UFS Short Range Weather (SRW) Application. 



Non-Container HPC-Stack Installation and Build 
=================================================

Install Prerequisites
----------------------

To install the HPC-Stack locally, the following pre-requisites must be installed:

* **Python 3:** Can be obtained either from the `main distributor <https://www.python.org/>`_ or from `Anaconda <https://www.anaconda.com/>`_. 
* **Compilers:** Distributions of Fortran, C, and C++ compilers that work for your system. 
* **Message Passing Interface (MPI)** libraries for multi-processor and multi-core communications, configured to work with your corresponding Fortran, C/C++ compilers. 
* **Programs and software packages:** `Lmod <https://lmod.readthedocs.io/en/latest/030_installing.html>`_, `CMake <https://cmake.org/install/>`_, `make <https://www.gnu.org/software/make/>`_, `wget <https://www.gnu.org/software/wget/>`_, `curl <https://curl.se/>`_, `git <https://git-scm.com/book/en/v2/Getting-Started-Installing-Git>`_

To determine whether these prerequisites are installed, query the environment variables (for ``Lmod``) or the location and version of the packages (for ``cmake``, ``make``, ``wget``, ``curl``, ``git``). A few examples:

   .. code-block:: console 

      echo $LMOD_PKG
      which cmake 
      cmake  --version 

If compilers or MPI's need to be installed, consult the :ref:`HPC-Stack Prerequisites <Prerequisites>` document for further guidance. 

.. _NonConConfigure:

Configure the Build
---------------------

Choose the COMPILER, MPI, and PYTHON version, and specify any other aspects of the build that you would like. For Level 1 systems, a default configuration can be found in the applicable ``config/config_<platform>.sh`` file. For Level 2-4 systems, selections can be made by editing the config/config_custom.sh file to reflect the appropriate compiler, mpi, and python choices for your system. If Lmod is installed on your system, you can view options using the ``module avail`` command. 
   
Some of the parameter settings available are: 

* HPC_COMPILER: This defines the vendor and version of the compiler you wish to use for this build. The format is the same as what you would typically use in a module load command. For example, HPC_COMPILER=intel/2020. Use ``gcc -v`` to determine your compiler and version. 
* HPC_MPI: This is the MPI library you wish to use. The format is the same as for HPC_COMPILER. For example: ``HPC_MPI=impi/2020``.
* HPC_PYTHON: This is the Python interpreter to use for the build. The format is the same as for HPC_COMPILER, for example: ``HPC_PYTHON=python/3.7.5``. Use ``python --version`` to determine the current version of Python. 

Other variables include USE_SUDO, DOWNLOAD_ONLY, NOTE, PKGDIR, LOGDIR, OVERWRITE, NTHREADS, MAKE_CHECK, MAKE_VERBOSE, and VENVTYPE. For more information on their use, see :ref:`HPC-Stack Parameters <HPCParameters>`. 

.. note:: 

   If you only want to install select components of the stack, you can edit the ``stack/stack_custom.yaml`` file to omit unwanted components. The ``stack/stack_custom.yaml`` file lists the software packages to be built along with their version, options, compiler flags, and any other package-specific options. A full listing of components is available in the :ref:`HPC-Stack Components <HPCComponents>` section.


.. _NonConSetUp:

Set Up Compiler, MPI, Python & Module System
-----------------------------------------------------

.. note::
   This step is required if you are using ``Lmod`` modules for managing the software stack. Lmod is installed across all Level 1 and Level 2 systems and in the containers provided. If ``LMod`` is not desired or used, the user can skip ahead to :numref:`Step %s <NonConHPCBuild>`.

Run from the top directory:

.. code-block:: console

   ./setup_modules.sh -p <prefix> -c <configuration>

where:

``<prefix>`` is the directory where the software packages will be installed with a default value $HOME/opt. The software installation trees will branch directly off of <prefix>, while the module files will be located in the <prefix>/modulefiles subdirectory. 

``<configuration>`` points to the configuration script that you wish to use, as described in :numref:`Step %s <NonConConfigure>`. The default configuration file is ``config/config_custom.sh``. 

**Additional Options:**

The compiler and mpi modules can be handled separately from the rest of the build in order to exploit site-specific installations that maximize performance. In this case, the compiler and mpi modules are preceded by an hpc- label. For example, to load the Intel compiler module and the Intel MPI (IMPI) software library, enter:

   .. code-block:: console

      module load hpc-intel/2020
      module load hpc-impi/2020

These hpc- modules are really meta-modules that load the compiler/mpi library and modify the MODULEPATH so that the user has access to the software packages that will be built in :numref:`Step %s <NonConHPCBuild>`. On HPC systems, these meta-modules load the native modules provided by the system administrators. 

In short, you may prefer not to load the compiler or MPI modules directly. Instead, loading the hpc- meta-modules as demonstrated above will provide everything needed to load software libraries.
   
It may be necessary to set certain source and path variables in the ``build_stack.sh`` script. For example:

   .. code-block:: console

      source /usr/share/lmod/6.6/init/bash
      source /usr/share/lmod/lmod/init/bash
      export PATH=/usr/local/sbin:/usr/local/bin:$PATH
      export LD_LIBRARY_PATH=/usr/local/lib64:/usr/local/lib:$LD_LIBRARY_PATH
      export LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH


.. _NonConHPCBuild:

Build the HPC-stack
--------------------

Now all that remains is to build the stack:

   .. code-block:: console

      ./build_stack.sh -p <prefix> -c <configuration> -y <yaml> -m

Here the -m option is only required if LMod is used for managing the software stack. It should be omitted otherwise. <prefix> and <configuration> are the same as in :numref:`Step %s <NonConSetUp>`, namely a reference to the installation prefix and a corresponding configuration file in the config directory. As in :numref:`Step %s <NonConSetUp>`, if this argument is omitted, the default is to use ``$HOME/opt`` and ``config/config_custom.sh`` respectively. <yaml> represents a user configurable yaml file containing a list of packages that need to be built in the stack along with their versions and package options. The default value of <yaml> is ``stack/stack_custom.yaml``.

.. warning:: 
   Steps :numref:`Step %s <NonConConfigure>`, :numref:`Step %s <NonConSetUp>`, and :numref:`Step %s <NonConHPCBuild>` need to be repeated for each compiler/MPI combination that you wish to install.** The new packages will be installed alongside any previously-existing packages that may already have been built from other compiler/MPI combinations.

From here, the user can continue to install and run applications that depend on the HPC-Stack, such as the UFS Short Range Weather (SRW) Application. 



