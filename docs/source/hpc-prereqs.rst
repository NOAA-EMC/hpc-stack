.. This is a continuation of the hpc-intro.rst chapter

.. _Prerequisites:

Installation of the HPC-Stack Prerequisites
=============================================

A wide variety of compiler and MPI options are available. Certain combinations may play well together, whereas others may not. 

The following system, compiler, and MPI combinations have been tested successfully:

+-----------------------------------+------------------------------------------+--------------------------------------------+
| System                            |  Compilers                                | MPI                                        |
+===================================+===========================================+============================================+
| SUSE Linux Enterprise Server 12.4 | Intel compilers 2020.0 (ifort, icc, icps) | Intel MPI wrappers (mpif90, mpicc, mpicxx) |
+-----------------------------------+-------------------------------------------+--------------------------------------------+
| Linux CentOS 7                    | Intel compilers 2020.0 (ifort, icc, icps) | Intel MPI (mpiifort, mpiicc, mpiicpc)      |
+-----------------------------------+-------------------------------------------+--------------------------------------------+

Compilers and MPI libraries can be downloaded from the following websites: 

Compilers: 
  * `GNU/GCC <https://gcc.gnu.org/>`__ (version 9.x)
  * `Intel <https://intel.com/`__

MPI's
  * `OpenMPI <https://www.open-mpi.org/)`__
  * `MPICH <https://www.mpich.org/)`__
  * `IntelMPI (IMPI) <https://www.intel.com/content/www/us/en/developer/tools/oneapi/mpi-library.html>`__

