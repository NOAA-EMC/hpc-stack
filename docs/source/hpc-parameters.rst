.. This is a continuation of the Installation.rst chapter

.. _HPCParameters:

Build Parameters
==========================

Compiler & MPI
----------------

``HPC_COMPILER``: 
   This defines the vendor and version of the compiler you wish to use for this build. The format is the same as what you would typically use in a module load command. For example, ``HPC_COMPILER=intel/2020``. Options include: 

   * ``gnu/6.5.0``
   * ``gnu/9.2.0``
   * ``intel/18.0.5.274``
   * ``intel/19.0.5.281``
   * ``intel/2020``
   * ``intel/2020.2``
   * ``intel/2021.3.0``

   For information on setting compiler flags, see :numref:`Section %s Additional Notes <Flags>`.

``HPC_MPI``: 
   The MPI library you wish to use for this build. The format is the same as for HPC_COMPILER; for example: ``HPC_MPI=impi/2020``. Current MPI types accepted are openmpi, mpich, impi, cray, and cray*. Options include:
   
   * ``impi/2020``
   * ``impi/2018.4.274``
   * ``impi/2019.0.5``
   * ``impi/2020``
   * ``impi/2020.2``
   * ``impi/2021.3.0``
   * ``mvapich2/2.3``
   * ``openmpi/4.1.2``

.. note:: 
   For example, when using Intel-based compilers and Intel's implementation of the MPI interface, the ``config/config_custom.sh`` should contain the following specifications: 

   .. code-block:: console

      export SERIAL_CC=icc
      export SERIAL_FC=ifort
      export SERIAL_CXX=icpc

      export MPI_CC=mpiicc
      export MPI_FC=mpiifort
      export MPI_CXX=mpiicpc

   This will set the C, Fortran, and C++ compilers and MPI's. 

.. note::
   To verify that your chosen MPI build (e.g., mpiicc) is based on the corresponding serial compiler (e.g., icc), use the ``-show`` option to query the MPI's. For example,
   
   .. code-block:: console

      mpiicc -show 

   will display output like this:

   .. code-block:: console

      $  icc  -I<LONG_INCLUDE_PATH_FOR_MPI>   -L<ANOTHER_MPI_LIBRARY_PATH>  -L<ANOTHER_MPI_PATH> -<libraries, liners, build options...>   -X<something>  --<enable/disable/with some options>  -l<library>   -l<another_library>  -l<yet-another-library>

   The message you need from this prompt is "icc", which confirms that your mpiicc build is based on icc.  It may happen that if you query the "mpicc -show" on your system, it is based on "gcc" (or something else).

Other Parameters
--------------------

``HPC_PYTHON``: 
   The Python interpretor you wish to use for this build. The format is the same as for ``HPC_COMPILER``, for example: ``HPC_PYTHON=python/3.7.5``. 

``USE_SUDO``: 
   If the directory where the software packages will be installed (``$PREFIX``) requires root permission to write to, such as ``/opt/modules``, then this flag should be enabled. For example, ``USE_SUDO=Y``.

``DOWNLOAD_ONLY``: 
   The stack allows the option to download the source code for all the software without performing the installation. This is especially useful for installing the stack on machines that do not allow internet connectivity to websites hosting the software (e.g., GitHub). For more information, see :numref:`Section %s Additional Notes <DownloadOnly>`.

.. note::

   To enable a boolean flag, use a single-digit ``Y`` or ``T``. To disable, use ``N`` or ``F`` (case insensitive).

``PKGDIR``: 
   is the directory where tarred or zipped software files will be downloaded and compiled. Unlike ``$PREFIX``, this is a relative path based on the root path of the repository. Individual software packages can be downloaded manually to this directory and untarred, but this is not required. Build scripts will look for the directory ``pkg/<pkgName-pkgVersion>`` (e.g., ``pkg/hdf5-1_10_3``).

``LOGDIR``: 
   The directory where log files from the build will be written, relative to the root path of the repository.

``OVERWRITE``: 
   If set to ``T``, this flag will cause the build script to remove the current installation, if any exists, and replace it with the new version of each software package in question. If this variable is not set, the build will bypass software packages that are already installed.

``NTHREADS``: 
   The number of threads to use for parallel builds.

``MAKE_CHECK``: 
   Run make check after build.

``MAKE_VERBOSE``: 
   Print out extra information to the log files during the build.

``VENVTYPE``: 
   Set the type of python environment to build. Value depends on whether using pip or conda. Set ``VENVTYPE=pyvenv`` when using pip and ``VENVTYPE=condaenv`` when using Miniconda for creating virtual environments. Default is ``pyvenv``.
