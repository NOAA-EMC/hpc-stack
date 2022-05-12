.. This is a continuation of the hpc-intro.rst chapter

.. _HPCComponents:

HPC-Stack Components
=====================

The HPC-Stack packages are built in :numref:`Step %s <NonConHPCBuild>` using the ``build_stack.sh`` script. The following software can optionally be built with the scripts under ``libs``. 

* **Compilers and MPI libraries**

  * `GNU/GCC <https://gcc.gnu.org/>`__
  * `Intel <https://intel.com>`__
  * `OpenMPI <https://www.open-mpi.org/>`__
  * `MPICH <https://www.mpich.org/>`__
  * ``hpc-`` Meta-modules for all the above as well as Intel and IMPI


* **HPC Stack - Third Party Libraries**

  * `CMake <https://cmake.org/>`__
  * `Udunits <https://www.unidata.ucar.edu/software/udunits/>`__
  * `PNG <http://www.libpng.org/pub/png/>`__
  * `JPEG <https://jpeg.org/>`__
  * `Jasper <https://github.com/jasper-software/jasper>`__
  * `SZip <https://support.hdfgroup.org/doc_resource/SZIP/>`__
  * `Zlib <http://www.zlib.net/>`__
  * `HDF5 <https://www.hdfgroup.org/solutions/hdf5/>`__
  * `PNetCDF <https://parallel-netcdf.github.io/>`__
  * `NetCDF <https://www.unidata.ucar.edu/software/netcdf/>`__
  * `ParallelIO <https://github.com/NCAR/ParallelIO>`__
  * `nccmp <https://gitlab.com/remikz/nccmp>`__
  * `nco <http://nco.sourceforge.net/>`__
  * `CDO <https://code.mpimet.mpg.de/projects/cdo>`__
  * `FFTW <http://www.fftw.org/>`__
  * `GPTL <https://jmrosinski.github.io/GPTL/>`__
  * Tau2
  * `Boost <https://beta.boost.org/>`__
  * `Eigen <http://eigen.tuxfamily.org/>`__
  * `GSL-Lite <http://github.com/gsl-lite/gsl-lite>`__
  * `JSON for C++ <https://github.com/nlohmann/json/>`__
  * `JSON Schema Validator for C++ <https://github.com/pboettch/json-schema-validator>`__
  * `pybind11 <https://github.com/pybind/pybind11>`__
  * `MADIS <https://madis-data.ncep.noaa.gov>`__
  * `SQLite <https://www.sqlite.org>`__
  * `PROJ <https://proj.org>`__
  * `GEOS <https://www.osgeo.org/projects/geos>`__


* **UFS Dependencies**

  * `ESMF <https://www.earthsystemcog.org/projects/esmf/>`__
  * `FMS <https://github.com/noaa-gfdl/fms.git>`__


* **NCEP Libraries**

  * `NCEPLIBS-bacio <https://github.com/noaa-emc/nceplibs-bacio.git>`__
  * `NCEPLIBS-sigio <https://github.com/noaa-emc/nceplibs-sigio.git>`__
  * `NCEPLIBS-sfcio <https://github.com/noaa-emc/nceplibs-sfcio.git>`__
  * `NCEPLIBS-gfsio <https://github.com/noaa-emc/nceplibs-gfsio.git>`__
  * `NCEPLIBS-w3nco <https://github.com/noaa-emc/nceplibs-w3nco.git>`__
  * `NCEPLIBS-sp <https://github.com/noaa-emc/nceplibs-sp.git>`__
  * `NCEPLIBS-ip <https://github.com/noaa-emc/nceplibs-ip.git>`__
  * `NCEPLIBS-ip2 <https://github.com/noaa-emc/nceplibs-ip2.git>`__
  * `NCEPLIBS-g2 <https://github.com/noaa-emc/nceplibs-g2.git>`__
  * `NCEPLIBS-g2c <https://github.com/noaa-emc/nceplibs-g2c.git>`__
  * `NCEPLIBS-g2tmpl <https://github.com/noaa-emc/nceplibs-g2tmpl.git>`__
  * `NCEPLIBS-nemsio <https://github.com/noaa-emc/nceplibs-nemsio.git>`__
  * `NCEPLIBS-nemsiogfs <https://github.com/noaa-emc/nceplibs-nemsiogfs.git>`__
  * `NCEPLIBS-w3emc <https://github.com/noaa-emc/nceplibs-w3emc.git>`__
  * `NCEPLIBS-landsfcutil <https://github.com/noaa-emc/nceplibs-landsfcutil.git>`__
  * `NCEPLIBS-bufr <https://github.com/noaa-emc/nceplibs-bufr.git>`__
  * `NCEPLIBS-wgrib2 <https://github.com/noaa-emc/nceplibs-wgrib2.git>`__
  * `NCEPLIBS-prod_util <https://github.com/noaa-emc/nceplibs-prod_util.git>`__
  * `NCEPLIBS-grib_util <https://github.com/noaa-emc/nceplibs-grib_util.git>`__
  * `NCEPLIBS-ncio <https://github.com/noaa-emc/nceplibs-ncio.git>`__
  * `NCEPLIBS-wrf_io <https://github.com/noaa-emc/nceplibs-wrf_io.git>`__
  * `EMC_crtm <https://github.com/noaa-emc/EMC_crtm.git>`__
  * `UPP <https://github.com/NOAA-EMC/UPP>`__


* **JEDI Dependencies**

  * `ecbuild <https://github.com/ecmwf/ecbuild.git>`__
  * `eckit <https://github.com/ecmwf/eckit.git>`__
  * `fckit <https://github.com/ecmwf/fckit.git>`__
  * `atlas <https://github.com/ecmwf/atlas.git>`__


* **Python and Virtual Environments**

  * `Miniconda3 <https://docs.conda.io/en/latest/>`__
  * `r2d2 <https://github.com/jcsda-internal/r2d2.git>`__

