.. _InstallBuildHPCstack:

================================
Install and Build the HPC-Stack
================================

.. attention::
   The HPC-Stack is already installed on `Level 1 <https://github.com/ufs-community/ufs-srweather-app/wiki/Supported-Platforms-and-Compilers>`__ systems (e.g., Cheyenne, Hera, Orion). Installation is not necessary. 

HPC-Stack installation will vary from system to system because there are so many possible combinations of operating systems, compilers, MPI's, and package versions. Installation via an EPIC-provided container is recommended to reduce this variability. However, users may choose a non-container approach to installation if they prefer. 

.. note:: 

   MPI stands for Message Passing Interface. An MPI is a standardized communication system used in parallel programming. It establishes portable and efficient syntax for the exchange of messages and data between multiple processors that are used by a single computer program. An MPI is required for high-performance computing (HPC). 


.. _SingularityInstall:

Install and Build the HPC-Stack in a Singularity Container
===========================================================

The Earth Prediction Innovation Center (EPIC) provides `several containers <https://github.com/NOAA-EPIC/ufs-containers>`__ available for the installation of the HPC-Stack either individually or combined with Unified Forecast System (UFS) applications: 

* `<docker://noaaepic/ubuntu20.04-gnu9.3>`__
* `<docker://noaaepic/ubuntu20.04-hpc-stack>`__
* `<docker://noaaepic/ubuntu20.04-epic-srwapp>`__
* `<docker://noaaepic/ubuntu20.04-epic-mrwapp>`__

Install Singularity
-----------------------

To install the HPC-Stack via Singularity container, first install the Singularity package according to the `Singularity Installation Guide <https://sylabs.io/guides/3.2/user-guide/installation.html#>`_. This will include the installation of dependencies and the installation of the Go programming language. SingularityCE Version 3.7 or above is recommended. 

.. warning:: 
   Docker containers can only be run with root privileges, and users cannot have root privileges on HPC's. Therefore, it is not possible to build the HPC-Stack inside a Docker container on an HPC system. A Docker image may be pulled, but it must be run inside a container such as Singularity. Docker can, however, be used to build the HPC-Stack on a *local* system. 


Build and Run the Container
----------------------------

#. Pull and build the container.

   .. code-block:: console

      singularity pull ubuntu20.04-gnu9.3.sif docker://noaaepic/ubuntu20.04-gnu9.3
      singularity build --sandbox ubuntu20.04-gnu9.3 ubuntu20.04-gnu9.3.sif
      cd ubuntu20.04-gnu9.3
   
   Make a directory (e.g., ``contrib``) in the container if one does not exist: 

   .. code-block:: console
         
      mkdir contrib
      cd ..

#. From the local working directory, start the container and run an interactive shell within it. This command also binds the local working directory to the container so that data can be shared between them.

   .. code-block:: console
      
      singularity shell -e --writable --bind /<local_dir>:/contrib ubuntu20.04-gnu9.3
   
   Make sure to update ``<local_dir>`` with the name of your local working directory. 


Build the HPC-Stack
--------------------

#. Clone the HPC-Stack repository (from inside the Singularity shell initialized above).
   
   .. code-block:: console
      
      git clone https://github.com/NOAA-EMC/hpc-stack
      cd hpc-stack

#. Set up the build environment. Be sure to change the ``prefix`` argument in the code below to your system's install location (likely within the ``hpc-stack`` directory). 
   
   .. code-block:: console
      
      ./setup_modules.sh -p <prefix> -c config/config_custom.sh

   Here, ``<prefix>`` is the directory where the software packages will be installed with a default value of ``$HOME/opt``. For example, if the HPC-Stack is installed in the user's directory, the prefix might be ``/home/$USER/hpc-stack/hpc-modules``.
   
   Enter YES/YES/YES when the option is presented. Then modify ``build_stack.sh`` with the following commands:
   
   .. code-block:: console

      sed -i "10 a source /usr/share/lmod/6.6/init/bash" ./build_stack.sh
      sed -i "10 a export PATH=/usr/local/sbin:/usr/local/bin:$PATH" ./build_stack.sh
      sed -i "10 a export LD_LIBRARY_PATH=/usr/local/lib64:/usr/local/lib:$LD_LIBRARY_PATH" ./build_stack.sh

#. Build the environment. This may take up to a couple of hours to complete. 
   
   .. code-block:: console

      ./build_stack.sh -p <prefix> -c config/config_custom.sh -y stack/stack_custom.yaml -m

#. Load the required modules, making sure to change the ``<prefix>`` to the location of the module files. 
   
   .. code-block:: console

      source /usr/share/lmod/lmod/init/bash
      module use <prefix>/hpc-modules/modulefiles/stack
      module load hpc hpc-gnu hpc-openmpi
      module avail

From here, the user can continue to install and run applications that depend on the HPC-Stack, such as the UFS Short Range Weather (SRW) Application. 


.. _NonContainerInstall:

Non-Container HPC-Stack Installation and Build (General/Linux)
================================================================

Install Prerequisites
----------------------

To install the HPC-Stack locally, the following pre-requisites must be installed:

* **Python 3:** Can be obtained either from the `main distributor <https://www.python.org/>`_ or from `Anaconda <https://www.anaconda.com/>`_. 
* **Compilers:** Distributions of Fortran, C, and C++ compilers that work for your system. 
* **Message Passing Interface (MPI)** libraries for multi-processor and multi-core communications, configured to work with your corresponding Fortran, C, and C++ compilers. 
* **Programs and software packages:** `Lmod <https://lmod.readthedocs.io/en/latest/030_installing.html>`_, `CMake <https://cmake.org/install/>`_, `make <https://www.gnu.org/software/make/>`_, `wget <https://www.gnu.org/software/wget/>`_, `curl <https://curl.se/>`_, `git <https://git-scm.com/book/en/v2/Getting-Started-Installing-Git>`_.

.. note::
   For detailed instructions on how to build the HPC-Stack on several configurations of MacOS, see :numref:`Chapter %s <MacInstall>`

To determine whether these prerequisites are installed, query the environment variables (for ``Lmod``) or the location and version of the packages (for ``cmake``, ``make``, ``wget``, ``curl``, ``git``). For example:

   .. code-block:: console 

      echo $LMOD_PKG
      which cmake 
      cmake --version 

If compilers or MPI's need to be installed, consult the :ref:`HPC-Stack Prerequisites <Prerequisites>` document for further guidance. MPI could also be built bundled with the HPC-stack, if not pre-installed in the system.

.. _UbuntuLinux:

Ubuntu Linux (20.04, 22.04) Example
-------------------------------------

The example for Ubuntu (tested for 20.04 and 22.04) is for a user with sudo privileges to install system-wide. First, install GNU 10 compilers:

.. code-block:: console

    sudo apt install gcc-10 g++-10
    sudo apt install gfortran-10
    which gcc 

The location of default compilers is likely be in ``/usr/bin/`` (e.g. /usr/bin/gcc), and other versions could be installed with the same location with the version tag. Check all the versions installed and configure the alternatives to specify which version is to be default. Below is the example when two versions are available, e.g., gcc-9 and gcc-10.

.. code-block:: console

    ls -la /usr/bin/gcc-*  
    sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10 1
    sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 2
    sudo update-alternatives --config gcc

Make selection (1) for gcc-10 to be the first priority (default).

Repeat similar steps to configure the alternatives for g++  and gfortran. No need to configure for gfortran if you have only a single version.

.. code-block:: console

    ls -la /usr/bin/g++-*  
    sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-10 1
    sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 2
    sudo update-alternatives --config g++

Install ``lua``, ``luac`` and ``tcl`` needed to support the ``Lmod`` module management system. Verify the installation location.

.. code-block:: console

    sudo apt-get install lua5.3 liblua5.3-0 liblua5.3-dev lua-filesystem-dev lua-posix-dev
    sudo apt-get install tcl tcl8.6-dev libtcl8.6
    which lua
    which luac
    
Standard installation paths for lua/luac are ``/usr/bin/lua`` and ``/usr/bin/luac``. 
Download and install Lmod, the module management environment, if not installed in the system. When installed, the environmental variable $LMOD_ROOT is usually defined: 

.. code-block:: console

    echo $LMOD_ROOT
    git clone https://github.com/TACC/Lmod.git 
    cd Lmod

See the INSTALL file for instructions; configure and install. Use the paths for ``lua`` and ``luac`` installed in the previous step. ``Lmod`` could be configured to be installed system-wide, or in user space as in the example below, e.g., in ``${HOME}/apps``. 

.. code-block:: console

    ./configure --with-lua=/usr/bin/lua  --with-luac=/usr/bin/luac --prefix=${HOME}/apps 
    make install

Add the Lmod environment initialization to your shell profile, 
i.e. to $HOME/.bash_profile (login bash session) or $HOME/.bashrc (non-login bash):

.. code-block:: console

    export BASH_ENV=$HOME/apps/lmod/lmod/init/profile        
    source $BASH_ENV

Install  wget, git, make and cmake; cmake could also be built bundled with the hpc-stack.

.. code-block:: console

    sudo apt install git
    sudo apt install wget
    sudo apt install make
    sudo apt install cmake  

Install openssl, libssl-dev packages:

.. code-block:: console

    sudo apt install openssl
    sudo apt-get install libssl-dev

Install make and cmake:

.. code-block:: console

    sudo apt install make
    sudo apt install cmake 

Both ``python2`` and ``python3`` are needed; python2 version higher than 2.7.x; python3 version higher than 3.6. Usually, ``python`` and ``python2`` are available with the Linux distribution. You could update ``python3`` if higher versions are available (python3.9 in the example below at the time of writing), and set the alternatives when multiple versions exist. The highest version among the existing python3.8 and python3.9 is set as a default in the example below (choose selection 1 for python3.9 when prompt). 

.. code-block:: console

    which python3 
    python3 --version 
    apt list | grep python  
    sudo apt install python3.9
    sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 1
    sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 2
    sudo update-alternatives --config python3  
    python3 --version  

Verify the version (python 3.9) set as default after the configuration. 


.. _NonConConfigure:

Configure the Build
---------------------

Choose the COMPILER, MPI, and PYTHON version, and specify any other aspects of the build that you would like. For `Level 1 <https://github.com/ufs-community/ufs-srweather-app/wiki/Supported-Platforms-and-Compilers>`__ systems, a default configuration can be found in the applicable ``config/config_<platform>.sh`` file. For Level 2-4 systems, selections can be made by editing the ``config/config_custom.sh`` file to reflect the appropriate compiler, MPI, and Python choices for your system. If Lmod is installed on your system, you can view package options using the ``module avail`` command. 
   
Some of the parameter settings available are: 

* HPC_COMPILER: This defines the vendor and version of the compiler you wish to use for this build. The format is the same as what you would typically use in a ``module load`` command. For example, ``HPC_COMPILER=intel/2020``. Use ``gcc -v`` to determine your compiler and version. 
* HPC_MPI: This is the MPI library you wish to use. The format is the same as for HPC_COMPILER. For example: ``HPC_MPI=impi/2020``.
* HPC_PYTHON: This is the Python interpreter to use for the build. The format is the same as for HPC_COMPILER, for example: ``HPC_PYTHON=python/3.7.5``. Use ``python --version`` to determine the current version of Python. 

Other variables include USE_SUDO, DOWNLOAD_ONLY, NOTE, PKGDIR, LOGDIR, OVERWRITE, NTHREADS, MAKE_CHECK, MAKE_VERBOSE, and VENVTYPE. For more information on their use, see :ref:`HPC-Stack Parameters <HPCParameters>`. 

.. note:: 

   If you only want to install select components of the HPC-Stack, you can edit the ``stack/stack_custom.yaml`` file to omit unwanted components. The ``stack/stack_custom.yaml`` file lists the software packages to be built along with their version, options, compiler flags, and any other package-specific options. A full listing of components is available in the :ref:`HPC-Stack Components <HPCComponents>` section.


.. _NonConSetUp:

Set Up Compiler, MPI, Python & Module System
-----------------------------------------------------

.. note::
   This step is required if you are using ``Lmod`` modules for managing the software stack. Lmod is installed across all Level 1 and Level 2 systems and in the containers provided. If ``LMod`` is not desired or used, the user can skip ahead to :numref:`Step %s <NonConHPCBuild>`.

After preparing the system configuration in ``./config/config_<platform>.sh``, run the following command from the top directory:

   .. code-block:: console

      ./setup_modules.sh -p <prefix> -c <configuration>

where:

``<prefix>`` is the directory where the software packages will be installed during the HPC-Stack build. The default value is $HOME/opt. The software installation trees will branch directly off of ``<prefix>``, while the module files will be located in the ``<prefix>/modulefiles`` subdirectory. 

.. attention::

   Note that ``<prefix>`` requires an absolute path; it will not work with a relative path.

``<configuration>`` points to the configuration script that you wish to use, as described in :numref:`Step %s <NonConConfigure>`. The default configuration file is ``config/config_custom.sh``. 

**Additional Options:**

The compiler and MPI modules can be handled separately from the rest of the build in order to exploit site-specific installations that maximize performance. In this case, the compiler and MPI modules are preceded by an ``hpc-`` label. For example, to load the Intel compiler module and the Intel MPI (IMPI) software library, enter:

   .. code-block:: console

      module load hpc-intel/2020
      module load hpc-impi/2020

These ``hpc-`` modules are really meta-modules that load the compiler/MPI library and modify the MODULEPATH so that the user has access to the software packages that will be built in :numref:`Step %s <NonConHPCBuild>`. On HPC systems, these meta-modules load the native modules provided by the system administrators. 

In short, you may prefer not to load the compiler or MPI modules directly. Instead, loading the hpc- meta-modules as demonstrated above will provide everything needed to load software libraries.
   
It may be necessary to set few environment variables in the ``build_stack.sh`` script. For example:
r

   .. code-block:: console

      export PATH=/usr/local/sbin:/usr/local/bin:$PATH
      export LD_LIBRARY_PATH=/usr/local/lib64:/usr/local/lib:$LD_LIBRARY_PATH
      export LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH

``Lmod`` needs to be initialized based on the installation directory:

   .. code-block:: console

      module purge
      export BASH_ENV=<Lmod-installation-dir>/lmod/lmod/init/profile
      source $BASH_ENV  
      export LMOD_SYSTEM_DEFAULT_MODULES=<module1>:<module2>:<module3>
      module --initial_load --no_redirect restore
      module use <$HOME>/<your-modulefiles-dir>

where: 

* ``<Lmod-installation-dir>`` is the top directory where Lmod is installed
* ``<module1>, ...,<moduleN>`` is a comma-separated list of modules to load by default
* ``<$HOME>/<your-modulefiles-dir>`` is the directory where additional custom modules may be built with Lmod (e.g., $HOME/modulefiles).

.. _NonConHPCBuild:

Build the HPC-Stack
--------------------

Now all that remains is to build the stack:

   .. code-block:: console

      ./build_stack.sh -p <prefix> -c <configuration> -y <yaml_file> -m

The the ``-m`` option is **required** to build the sofware stack as modules for Lmod environment, which is usually needed. It could be omitted to build the libraries with no module environment. ``<prefix>`` and ``<configuration>`` are the same as in :numref:`Step %s <NonConSetUp>`, namely a reference to the absolute-path installation prefix and a corresponding configuration file in the ``config`` directory. As in :numref:`Step %s <NonConSetUp>`, if this argument is omitted, the default is to use ``$HOME/opt`` and ``config/config_custom.sh`` respectively. ``<yaml_file>`` represents a user configurable yaml file containing a list of packages that need to be built in the stack along with their versions and package options. The default value of ``<yaml_file>`` is ``stack/stack_custom.yaml``.

.. warning:: 
   Steps :numref:`Step %s <NonConConfigure>`, :numref:`Step %s <NonConSetUp>`, and :numref:`Step %s <NonConHPCBuild>` need to be repeated for each compiler/MPI combination that you wish to install. The new packages will be installed alongside any previously-existing packages that may already have been built from other compiler/MPI combinations.

From here, the user can continue to install and run applications that depend on the HPC-Stack.

