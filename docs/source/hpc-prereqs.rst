.. This is a continuation of the hpc-intro.rst chapter

.. _Prerequisites:

Installation of the HPC-Stack Prerequisites
=============================================

A wide variety of compiler and MPI options are available. Certain combinations may play well together, whereas others may not. 

The following system, compiler, and MPI combinations have been tested successfully:

.. table::  Sample System, Compiler, and MPI Options

   +------------------------+-------------------------+-----------------------------+
   | **System**             |  **Compilers**          | **MPI**                     |
   +========================+=========================+=============================+
   | SUSE Linux Enterprise  | Intel compilers 2020.0  | Intel MPI wrappers          |
   | Server 12.4            | (ifort, icc, icps)      | (mpif90, mpicc, mpicxx)     |
   +------------------------+-------------------------+-----------------------------+
   | Linux CentOS 7         | Intel compilers 2020.0  | Intel MPI                   |
   |                        | (ifort, icc, icps)      | (mpiifort, mpiicc, mpiicpc) |
   +------------------------+-------------------------+-----------------------------+
   | Linux Ubuntu20.04      | GNU 10.3 compilers      | MPICH                       |
   |                        | (gcc, g++, gfortran)    | (mpif90, mpicc, mpicxx)     |
   +------------------------+-------------------------+-----------------------------+
   | MacOS X x86_64 (Intel) | GNU 11.2 compilers      | OpenMPI                     |
   | Darwin19 (Catalina)    | (gcc, g++, gfortran)    | (mpif90, mpicc, mpicxx)     |
   +------------------------+-------------------------+-----------------------------+
   | MacOS X arm64 (M1)     | GNU 11.2 compilers      | OpenMPI                     |
   | Darwin20 (BigSur)      | (gcc, g++, gfortran)    | (mpif90, mpicc, mpicxx)     |
   +------------------------+-------------------------+-----------------------------+

Compilers and MPI libraries can be downloaded from the following websites: 

Compilers: 
  * `GNU/GCC <https://gcc.gnu.org/>`__ (version 9.x)
  * `Intel <https://intel.com/>`__

MPI's
  * `OpenMPI <https://www.open-mpi.org/>`__
  * `MPICH <https://www.mpich.org/>`__
  * `IntelMPI <https://www.intel.com/content/www/us/en/developer/tools/oneapi/mpi-library.html>`__

