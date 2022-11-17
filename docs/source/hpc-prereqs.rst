.. This is a continuation of the hpc-intro.rst chapter

.. _Prerequisites:

Installation of the HPC-Stack Prerequisites
=============================================

A wide variety of compiler and MPI options are available. Certain combinations may play well together, whereas others may not. Some examples and installation instructions are given in previous Sections for Ubuntu Linux (:numref:`Chapter %s <NonContainerInstall>`) and MacOS (:numref:`Chapter %s <MacInstall>`).  

The following system, compiler, and MPI combinations have been tested successfully:

.. table::  Sample System, Compiler, and MPI Options

   +-------------------------+-------------------------+-----------------------------+
   | **System**              |  **Compilers**          | **MPI**                     |
   +=========================+=========================+=============================+
   | SUSE Linux Enterprise   | Intel compilers 2020.0  | Intel MPI wrappers          |
   | Server 12.4             | (ifort, icc, icps)      | (mpif90, mpicc, mpicxx)     |
   +-------------------------+-------------------------+-----------------------------+
   | Linux CentOS 7          | Intel compilers 2020.0  | Intel MPI                   |
   |                         | (ifort, icc, icps)      | (mpiifort, mpiicc, mpiicpc) |
   +-------------------------+-------------------------+-----------------------------+
   | Linux Ubuntu 20.04,22.04| GNU compilers 10.3      | MPICH 3.3.2                 |
   |                         | (gcc, g++, gfortran)    | (mpifort, mpicc, mpicxx)    |
   +-------------------------+-------------------------+-----------------------------+
   | MacOS M1/arm64 arch.    | GNU compilers 10.2,11.3 | OpenMPI 4.1.2               |
   |  Darwin20 (BigSur)      | (gcc, g++, gfortran)    | (mpifort, mpicc, mpicxx)    |
   +-------------------------+-------------------------+-----------------------------+
   | MacOS Intel x86_64      | GNU compilers 10.2      | OpenMPI 4.1.2, MPICH 3.3.2  |
   |   Darwin19 (Catalina)   | (gcc, g++, gfortran)    | (mpifort, mpicc, mpicxx)    |  
   +-------------------------+-------------------------+-----------------------------+
   | MacOS Intel x86_64      | GNU compilers 11.3      | OpenMPI 4.1.2               |
   |   Darwin21 (Monterey)   | (gcc, g++, gfortran)    | (mpifort, mpicc, mpicxx)    |  
   +-------------------------+-------------------------+-----------------------------+

Compilers and MPI libraries can be downloaded from the following websites: 

Compilers: 
  * `GNU/GCC <https://gcc.gnu.org/>`__ (version 11.x)
  * `Intel <https://intel.com/>`__

MPI's
  * `OpenMPI <https://www.open-mpi.org/>`__
  * `MPICH <https://www.mpich.org/>`__
  * `IntelMPI <https://www.intel.com/content/www/us/en/developer/tools/oneapi/mpi-library.html>`__

