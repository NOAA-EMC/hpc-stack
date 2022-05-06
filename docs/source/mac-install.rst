.. _MacInstall:


Install and Build HPC-Stack on MacOS
==========================================

HPC-Stack can be installed and built on MacOS systems. The following two options have been tested:

* **Option 1:** MacBookAir 2020, M1 chip (arm64, running natively), 4+4 cores, Big Sur 11.6.4, GNU compiler suite v.11.2.0_3 (gcc, gfortran, g++); no MPI pre-installed

* **Option 2:** MacBook Pro 2015, 2.8 GHz Quad-Core Intel Core i7 (x86_64), Catalina OS X 10.15.7, GNU compiler suite v.11.2.0_3 (gcc, gfortran, g++); no MPI pre-installed

.. note::
    Examples throughout this chapter presume that the user is running Terminal.app with a bash shell environment. If this is not the case, users will need to adjust commands to fit their command line application and shell environment. 

Prerequisites for Building HPC-Stack
----------------------------------------

Install Homebrew and Xcode Command-Line Tools (CLT)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Open Terminal.app and a web browser. Go to https://brew.sh, copy the command-line installation directive, and run it in a new Terminal window. Terminal will request a ``sudo`` access password. The installation command will look similar to the following:

.. code-block:: console

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

This will install Homebrew, Xcode CLT, and Ruby. 

An alternative way to install the Xcode command-line tools (CLT) is as follows:

.. code-block:: console

    xcode-select --install 

Install Compilers
^^^^^^^^^^^^^^^^^^^^^

Install GNU compiler suite (version 11) and gfortran: 

.. code-block:: console

    brew install gcc@11 

Create symbolic links from the version-specific binaries to gcc and g++.  A ``sudo`` password may be requested. The path will likely be ``/opt/homebrew/bin/gcc-11`` (Option 1), or ``/usr/local/bin/gcc-11`` (Option 2). 

.. code-block:: console

    which gcc-11    
    cd /usr/local/bin/        (OR cd /opt/homebrew/bin/ )
    ln -s gcc-11 gcc  
    ln -s g++-11 g++

There is no need to create a link for gfortran if this is the first installation of this compiler. If an earlier version of gfortran exists, you may rename it (e.g., to "gfortran-old") and create a link to the new installation:

.. code-block:: console

    ln -s gfortran-11 gfortran

Verify the paths for the compiler binaries:

.. code-block:: console

    which gcc
    which g++
    which gfortran 

Verify that they show the correct version of GNU installed:

.. code-block:: console

    gcc --version
    g++ --version
    gfortran --version 

Install CMake
^^^^^^^^^^^^^^^^^^^^^

Install the cmake utility via homebrew:

.. code-block:: console

    brew install cmake


Install/Upgrade Make
^^^^^^^^^^^^^^^^^^^^^^^

To install the make utility via homebrew:

.. code-block:: console

    brew install make

To upgrade the make utility via homebrew:

.. code-block:: console

    brew upgrade make



.. _InstallLmod:

Install Lmod
^^^^^^^^^^^^^^^^

Install Lmod, the module management environment: 

.. code-block:: console

    brew install lmod

You may need to add the Lmod environment initialization to your shell profile, e.g., to ``$HOME/.bashrc``. 

For the Option 1 installation, add: 

.. code-block:: console

    source /opt/homebrew/opt/lmod/init/profile

For the Option 2 installation, add:

.. code-block:: console

    source /usr/local/opt/lmod/init/profile

.. _InstallLibpng:

Install libpng 
^^^^^^^^^^^^^^^^^^^

The libpng library has issues when building on MacOS during the HPC-Stack bundle build. Therefore, it must be installed separately. To install the libpng library, run:

.. code-block:: console

    brew install libpng 


Install wget
^^^^^^^^^^^^^^^^

Install the Wget software package:

.. code-block:: console

    brew install wget

.. _InstallPython:

Install or Update Python3 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

First, verify that Python3 is installed, and check the current version:

.. code-block:: console

    which python3
    python3 --version

The first command should return ``/usr/bin/python3`` and the second should return ``Python 3.8.2`` or similar (the exact version is unimportant).

If necessary, download an updated version of Python3 for MacOS from https://www.python.org/downloads. The version 3.9.11 64-bit universal2 installer package is recommended (i.e., ``python-3.9.11-macos11.pkg``). Double-click on the installer package, and accept the license terms. An administrative level password will be requested for the installation. At the end of the installation, run ``Install Certificates.command`` by double-clicking on the shell script in Finder.app that opens and runs it. 

Start a new bash session (type ``bash`` in the existing terminal), and verify the installed version:

.. code-block:: console

    python3 --version

The output should now correspond to the Python version you installed. 

Install Git
^^^^^^^^^^^^^^^

Install git and dependencies:

.. code-block:: console

    brew install git



Building HPC-Stack
--------------------

Clone HPC-Stack
^^^^^^^^^^^^^^^^^^

Download HPC-Stack code from `GitHub <github.com>`__: 

.. code-block:: console 

    git clone git@github.com:NOAA-EMC/hpc-stack.git
    cd hpc-stack

The configuration files are ``./config/config_<machine>.sh``. For Option 1, ``<machine>`` is ``mac_m1_gnu`` and for Option 2, ``<machine>`` is ``mac_gnu``. 

The ``./stack/stack_<machine>.yaml`` file lists the libraries that will be built as part of HPC-Stack, in addition to library-specific options. These can be altered based on user preferences. 

Lmod Environment
^^^^^^^^^^^^^^^^^^^

Verify the initialization of Lmod environment, or add it to the configuration file ``./config/config_<machine>.sh``, as in :numref:`Step %s <InstallLmod>`.

For Option 1: 

.. code-block:: console 

    source /opt/homebrew/opt/lmod/init/profile

For Option 2:

.. code-block:: console 

    source /usr/local/opt/lmod/init/profile


Specify Compiler, Python, and MPI
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Specify the combination of compilers, python libraries, and MPI libraries in the configuration file ``./config/config_<machine>.sh``.

.. code-block:: console 

    export HPC_COMPILER="gnu/11.2.0_3"
    export HPC_MPI="openmpi/4.1.2"      (Option 1 only)  
    export HPC_MPI="mpich/3.3.2"        (Option 2 only)
    export HPC_PYTHON="python/3.10.2"

Comment out any export statements not relevant to the system, and make sure that version numbers reflect the versions installed on the system (which may differ from the versions listed here). 


Set Appropriate Flags
^^^^^^^^^^^^^^^^^^^^^^^^

When using gfortran version 10 or higher, verify that the following flags are set in ``config_<machine>.sh``: 

For Option 1:

.. code-block:: console 

    export STACK_FFLAGS="-fallow-argument-mismatch -fallow-invalid-boz" 
    

For Option 2:

.. code-block:: console 

    export STACK_FFLAGS=“-fallow-argument-mismatch -fallow-invalid-boz”
    export STACK_CXXFLAGS="-march=native" 

Set Environment Variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Set the environmental variables for compiler paths in ``./config/config_<machine>.sh``. The variable ``GNU`` below refers to the directory where the compiler binaries are located. For example, with Option 1, ``GNU=/opt/homebrew/bin/gcc``, and with Option 2: ``GNU=/usr/local/bin``. 

.. code-block:: console 

    export GNU="path/to/compiler/binaries"
    export CC=$GNU/gcc
    export FC=$GNU/gfortran
    export CXX=$GNU/g++
    export SERIAL_CC=$GNU/gcc
    export SERIAL_FC=$GNU/gfortran
    export SERIAL_CXX=$GNU/g++


Specify MPI Libraries
^^^^^^^^^^^^^^^^^^^^^^^^

Specify the MPI libraries to be built within the HPC-Stack in ``./stack/stack_<machine>.yaml``. The ``openmpi/4.1.2`` (Option 1) and ``mpich/3.3.2`` (Option 2) have been built successfully.

Option 1: 

.. code-block:: console 

    mpi:
    build: YES
    flavor: openmpi
    version: 4.1.2

Option 2:

.. code-block:: console 

    mpi:
    build: YES
    flavor: mpich
    version: 3.3.2

Libpng
^^^^^^^^^

Set build ``libpng`` library to NO in ``./stack/stack_<machine>.yaml`` to avoid problems during the HPC-Stack build. Leave the defaults for other libraries and versions in ``./stack/stack_<machine>.yaml``. 

.. code-block:: console

    libpng:
    build: NO


Set Up the Modules and Environment
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Set up the modules and environment:

.. code-block:: console 

    ./setup_modules.sh -c config/config_<machine>.sh -p $HPC_INSTALL_DIR | tee setup_modules.log

where ``<machine>`` is ``mac_m1_gnu`` (Option 1), or ``mac_gnu`` (Option 2), and ``$HPC_INSTALL_DIR`` is the *absolute* path for the installation directory of the HPC-Stack. You will be asked to choose whether or not to use "native" installations of Python, the compilers, and the MPI. "Native" means that they are already installed on your system. Thus, you answer "YES" to python, "YES" to gnu compilers, and "NO" for MPI/mpich. 

Building HPC-Stack
^^^^^^^^^^^^^^^^^^^^^

Build the modules: 

.. code-block:: console

    ./build_stack.sh -c config/config_<machine>.sh -p $HPC_INSTALL_DIR  -y stack/stack_<machine>.yaml -m 2>&1 | tee build_stack.log

.. attention:: 
    * The option ``-p`` requires an absolute path (full path) of the installation directory!
    * The ``-m`` option is needed to build separate modules for each library package.

