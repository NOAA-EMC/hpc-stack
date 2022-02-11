**Definition:** HPC-stack is a repository that provides a unified, shell script-based build system for 
building the software stack required for the `Unified Forecast System (UFS) <https://ufscommunity.org/>`_ and applications. 

Background
------------------------
The UFS Weather Model draws on over 50 code libraries to run its applications. These libraries range from libraries developed in-house at NOAA (e.g. NCEPLIBS, FMS, etc.) to libraries developed by NOAA's partners (e.g. PIO, ESMF etc) to truly third party libraries (e.g. NETCDF). Individual installation of these libraries is not practical, so the `HPC-Stack <https://github.com/NOAA-EMC/hpc-stack>`_ was developed as a central installation system to ensure that the infrastructure environment across multiple platforms is as similar as possible. Installation of the HPC-Stack is required to run the SRW. 

Instructions
-------------------------
`Level 1 <https://github.com/ufs-community/ufs-srweather-app/wiki/Supported-Platforms-and-Compilers>`_ platforms (e.g. Cheyenne, Hera) already have the HPC-Stack installed. Users on those platforms do *not* need to install the HPC-Stack before building UFS applications (e.g. SRW, MRW) or models. Users working on systems that fall under `Support Levels 2-4 <https://github.com/ufs-community/ufs-srweather-app/wiki/Supported-Platforms-and-Compilers>`_ will need to install the HPC-Stack the first time they try to run UFS applications or models.

Users can either build the HPC-stack on their local system or use the centrally maintained stacks on each HPC platform. For a detailed description of installation options, see :doc:`Installing the HPC-Stack <hpc-install>`.  

.. note::
   `HPC-Stack <https://github.com/NOAA-EMC/hpc-stack.git>`_ is part of the NCEPLIBS project and was originally written for the `Joint Effort for Data assimilation Integration (JEDI) <https://jointcenterforsatellitedataassimilation-jedi-docs.readthedocs-hosted.com/en/latest/>`_ framework.








