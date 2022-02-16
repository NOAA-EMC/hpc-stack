**Definition:** The HPC-stack is a repository that provides a unified, shell script-based build system for building the software stack required for numerical weather prediction (NWP) tools such as the `Unified Forecast System (UFS) <https://ufscommunity.org/>`_ and the Joint Effort for Data assimilation Integration (JEDI) framework. 

Background
------------------------
The `HPC-Stack <https://github.com/NOAA-EMC/hpc-stack.git>`_ provides libraries and dependencies in a consistent manner for NWP applications. It is part of the `NCEPLIBS project <https://github.com/NOAA-EMC/NCEPLIBS>`_ and is model/system agnostic. The HPC-Stack was originally written to facilitate installation of third-party libraries in a systematic manner on macOS and Linux systems (specifically RHEL). It was later transferred, expanded and further enhanced in the `Joint Effort for Data assimilation Integration (JEDI) <https://jointcenterforsatellitedataassimilation-jedi-docs.readthedocs-hosted.com/en/latest/>`_ project.

Instructions
-------------------------
`Level 1 <https://github.com/ufs-community/ufs-srweather-app/wiki/Supported-Platforms-and-Compilers>`_ platforms (e.g. Cheyenne, Hera) already have the HPC-Stack installed. Users on those platforms do *not* need to install the HPC-Stack before building UFS applications (e.g. SRW, MRW) or models. Users working on systems that fall under `Support Levels 2-4 <https://github.com/ufs-community/ufs-srweather-app/wiki/Supported-Platforms-and-Compilers>`_ will need to install the HPC-Stack the first time they try to run UFS applications or models.

Users can either build the HPC-stack on their local system or use the centrally maintained stacks on each HPC platform. For a detailed description of installation options, see :ref:`Installing the HPC-Stack <InstallBuildHPCstack>`.  









