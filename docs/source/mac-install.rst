.. _MacInstall:


Install and Build HPC-Stack on MacOS
==========================================

HPC-Stack can be installed and built on MacOS systems with either M1/arm64 or x86_64 architecture. The following options have been tested:

* MacBookAir 2020, **M1** chip (**arm64, running natively**), 4+4 cores, Big Sur 11.6.4, GNU compiler suite v.11.3.0 (gcc, gfortran, g++); no MPI pre-installed

* MacBookPro 2015, **x86_64**, 2.8 GHz Quad-Core Intel Core i7, Catalina OS X 10.15.7, GNU compiler suite v.11.3.0 (gcc, gfortran, g++); no MPI pre-installed

* MacBookPro 2019, **x86_64**, 2.4 GHz 8-core Intel Core i9, Monterey OS X 12.6.1, GNU compiler suite v.11.3.0 (gcc, gfortran, g++); no MPI pre-installed

.. note::
    Examples throughout this chapter presume that the user is running Terminal.app with a bash shell environment. If this is not the case, users will need to adjust commands to fit their command line application and shell environment. 

Prerequisites for Building HPC-Stack
----------------------------------------

Install Homebrew and Xcode Command-Line Tools (CLT)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Open Terminal.app and a web browser. Go to https://brew.sh, copy the command-line installation directive, and run it in a new Terminal window. The installation command will look similar to the example below. A ``sudo`` access password will be promted to proceed with the installation. 

.. code-block:: console

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

This will install Homebrew, and on some systems, also Xcode CLT, and Ruby. 

An alternative way to install the Xcode command-line tools (CLT) is as follows:

.. code-block:: console

    xcode-select --install 

Note the messages at the end of the installation. Users may need to update the environment variable ``$PATH`` and add it to the shell initialization, such as $HOME/.bash_profile (login shell), and $HOME/.bashrc (non-login interactive shell). 

When XCode >= 14.x.x is installed on higher versions of MacOS (Ventura OS 13.x.x), some issues with linking executables in the end of building the hpc-stack have been reported. A suggested workaround was to downgrade the XCode to 13.x.x version. Verify the version of the XCode CLT:

.. code-block:: console

    pkgutil --pkgs
    # There likely be a package named 'com.apple.pkg.CLTools_macOS_SDK'
    pkgutil --pkg-info com.apple.pkg.CLTools_macOS_SDK


Homebrew installs packages in their own independent directories, and subsequently creates links to package locations from a standard installation path. It is usually ``/home/homebrew/`` on systems with M1 (arm64), or ``/usr/local/`` on Intel (x86_64) systems. The Standard installation path could be queued using ``brew --prefix``. The instructions below set an environmentl variable ``$BREW`` for architecture-independent path substitutions: 

.. code-block:: console

   BREW=$(brew --prefix)
   export PATH=$BREW/bin:$PATH
   echo 'export PATH="$BREW/bin:$PATH"' >> ~/.bashrc

Install Compilers
^^^^^^^^^^^^^^^^^^^^^

Install GNU compiler suite (version 11) with gfortran: 

.. code-block:: console

    brew install gcc@11 

Create symbolic links from the version-specific binaries to ``gcc``, ``g++``, and ``gfortran``. You will likely be prompted for a ``sudo`` password. If previous versions of gcc, g++ or gfortran exist, it is recommended to rename them. For example, if existing gcc is version 9 ('gcc --version'   

.. code-block:: console

    which gcc-11    
    cd $BREW/bin/  
    ln -s gcc-11 gcc  
    ln -s g++-11 g++

Verify that compiler path installed using Homebrew, ``$BREW\bin`` takes precedence over  ``/usr/bin`` path with system compilers: ``echo $PATH``.  
    
Check if a previous version of gfortran exists; rename it in that case (e.g., to "gfortran-X") and create a link to a newer binary:

.. code-block:: console

    which gfortran 
    mv gfortran gfortran-X
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

Install the cmake utility via Homebrew:

.. code-block:: console

    brew install cmake


Install/Upgrade Make
^^^^^^^^^^^^^^^^^^^^^^^

To install or upgrade the make utility via Homebrew, use either one of the following:

.. code-block:: console

    brew install make
    brew upgrade make


.. _InstallOpenssl:

Install Openssl@3
^^^^^^^^^^^^^^^^^^^^^
To install the openssl@3 package, run:

.. code-block:: console

   brew install openssl@3

Note the messages at the end of the installation. Depending on what they say, users may need to add the location of the openssl@3 binaries to the environment variable ``$PATH``. To add it to the ``PATH``, run:

.. code-block:: console

   echo 'export PATH="$BREW/opt/openssl@3/bin:$PATH"' >> ~/.bashrc

Users may also need to set certain flags so that the compilers can find the openssl@3 package:

.. code-block:: console

   export LDFLAGS+=" -L$BREW/opt/openssl@3/lib "
   export CPPFLAGS+=" -I$BREW/opt/openssl@3/include "


.. _InstallLmod:

Install Lmod
^^^^^^^^^^^^^^^^

Install Lmod, which is the module management environment, run: 

.. code-block:: console

    brew install lmod

You may need to add the Lmod environment initialization to your shell profile, e.g., to ``$HOME/.bashrc``. 

.. code-block:: console

   export BASH_ENV="$BREW/opt/lmod/init/profile"
   source $BASH_ENV


Install wget
^^^^^^^^^^^^^^^^

Install the Wget software package:

.. code-block:: console

    brew install wget

    which python3
.. _InstallPython:

Install or Update Python3 and Python2 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

First, verify whether python (python2) and python3 are installed, and check the current version:

.. code-block:: console

    which python
    python --version
    which python2
    python2 --version
    which python3
    python3 --version

The query for python3 in the last two lines in the code block above may return something similar to ``/usr/bin/python3`` and ``Python 3.8.2``, respectively (the exact version is unimportant).

Python (python2.7.x) is no longer provided with the MacOS version 12.3 (Monterey), but is a part of standard MacOS for earlier versions. If there is no other need to install python2, you may install python3, and then create a symbolic link to set it as a default ``python``. The example below shows python3 installed using Homebrew with the path ``$BREW/bin/python3``, and subsequent link created:

.. code-block:: console

    brew install python3
    cd $BREW/bin
    ln -s python3 python

Another way to create a link is from one of User's directories, e.g., $HOME/bin, which could be added to the search $PATH for binaries:

.. code-block:: console

    which python3
    ln -s $BREW/bin/python3 $HOME/bin/python
    export PATH="$HOME/bin/python:$PATH"
    echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
    which python

Install Git and Git-lfs
^^^^^^^^^^^^^^^^^^^^^^^^^^

Install git, dependencies, and git-lfs:

.. code-block:: console

    brew install git
    brew install git-lfs


Building HPC-Stack
--------------------

Clone HPC-Stack
^^^^^^^^^^^^^^^^^^

Download HPC-Stack code from `GitHub <github.com>`__: 

.. code-block:: console 

    git clone https://github.com/NOAA-EMC/hpc-stack.git
    cd hpc-stack

An alternative and more updated location for the hpc-stack is on NOAA-EPIC repository: https://github.com/NOAA-EPIC/hpc-stack.git

The example of a configuration file is ``./config/config_macos_gnu.sh``. 

The ``./stack/stack_macos.yaml`` file lists the libraries that will be built as part of HPC-Stack, in addition to library-specific options. These can be altered based on user preferences and particular application for which the HPC-stack is being built. 

Lmod Environment
^^^^^^^^^^^^^^^^^^^

Verify the initialization of Lmod environment, or add it to the configuration file ``./config/config_macos_gnu.sh``, as in :numref:`Step %s <InstallLmod>`.

.. code-block:: console 

   export BASH_ENV="$BREW/opt/lmod/init/profile"
   source $BASH_ENV


Specify Compiler, Python, and MPI
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Specify the combination of compilers, python libraries, and MPI libraries in the configuration file ``./config/config_macos_gnu.sh``.

.. code-block:: console 

    export HPC_COMPILER="gnu/11.3.0"
    export HPC_MPI="openmpi/4.1.2" 
    export HPC_PYTHON="python/3.10.2"

Comment out any export statements not relevant to the system, and make sure that version numbers reflect the versions installed on the system (which may differ from the versions listed here). 


Set Appropriate Flags
^^^^^^^^^^^^^^^^^^^^^^^^

When using gfortran version 10 or higher, verify that the following flags are set in ``config_macos_gnu.sh``: 

.. code-block:: console 

    export STACK_FFLAGS=“-fallow-argument-mismatch -fallow-invalid-boz”
    export STACK_CXXFLAGS="-march=native" 

Set Environment Variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Set the environmental variables for compiler paths in ``./config/config_macos_gnu.sh``. 

.. code-block:: console 

    BREW=$(brew --prefix)
    export CC=$BREW/bin/gcc
    export FC=$BREW/bin/gfortran
    export CXX=$BREW/bin/g++
    export SERIAL_CC=$BREW/bin/gcc
    export SERIAL_FC=$BREW/bin/gfortran
    export SERIAL_CXX=$BREW/bin/g++


Specify MPI Libraries
^^^^^^^^^^^^^^^^^^^^^^^^

Specify the MPI libraries to be built within the HPC-Stack in ``./stack/stack_macos.yaml``. When using GNU compilers installed with Homebrew, specify _NOT_ to build ``gnu`` compilers, and to build ``mpi`` libraries. The ``openmpi/4.1.2`` has been built successfully on all the systems, and ``mpich/3.3.2`` on some.

.. code-block:: console 

    gnu:
      build: NO
      version: 11.3.0

    mpi:
    build: YES
    flavor: openmpi
    version: 4.1.2

You could leave the defaults for other libraries and versions in ``./stack/stack_macos.yaml``. 


Set Up the Modules and Environment
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Set up the modules and environment:

.. code-block:: console 

    ./setup_modules.sh -c config/config_macos_gnu.sh -p $HPC_INSTALL_DIR | tee setup_modules.log

where the ``$HPC_INSTALL_DIR`` is the *absolute* path of the HPC-stack installation directory. The $HPC_INSTALL_DIR needs to be different from the source directory, where you build and compile the software stack. When asked whether to use "native" Python or compilers, choose "YES" if using those already installed on your system, or "NO" if they will be built during the HPC-stack installation. The likely response is to answer "YES" to python, "YES" to compilers, and "NO" for MPI/openmpi. 

Building HPC-Stack
^^^^^^^^^^^^^^^^^^^^^

Build the modules: 

.. code-block:: console

    ./build_stack.sh -c config/config_macos_gnu.sh -p $HPC_INSTALL_DIR  -y stack/stack_macos.yaml -m 2>&1 | tee build_stack.log

.. attention:: 
    * The option ``-p`` requires an absolute path (full path) of the installation directory!
    * The ``-m`` option is needed to build separate modules for each library package.

