.. _Intro:

======================
Introduction
======================

**Definition:** The HPC-Stack is a repository that provides a unified, shell script-based build system to build the software stack required for numerical weather prediction (NWP) tools such as the `Unified Forecast System (UFS) <https://ufscommunity.org/>`__ and the `Joint Effort for Data assimilation Integration (JEDI) <https://jointcenterforsatellitedataassimilation-jedi-docs.readthedocs-hosted.com/en/latest/>`__ framework. 

Background
------------------------
The `HPC-Stack <https://github.com/NOAA-EMC/hpc-stack.git>`__ provides libraries and dependencies in a consistent manner for NWP applications. It is part of the `NCEPLIBS project <https://github.com/NOAA-EMC/NCEPLIBS>`__ and is model/system agnostic. The HPC-Stack was originally written to facilitate installation of third-party libraries in a systematic manner on macOS and Linux systems (specifically RHEL). It was later transferred, expanded and further enhanced in the `Joint Effort for Data assimilation Integration (JEDI) <https://jointcenterforsatellitedataassimilation-jedi-docs.readthedocs-hosted.com/en/latest/>`__ project.

Instructions
-------------------------
`Level 1 <https://github.com/ufs-community/ufs-srweather-app/wiki/Supported-Platforms-and-Compilers>`__ platforms (e.g., Cheyenne, Hera) already have the HPC-Stack installed. Users on those platforms do *not* need to install the HPC-Stack before building applications or models that require the HPC-Stack. Users working on systems that fall under `Support Levels 2-4 <https://github.com/ufs-community/ufs-srweather-app/wiki/Supported-Platforms-and-Compilers>`_ will need to install the HPC-Stack the first time they try to run applications or models that depend on it.

Users can either build the HPC-Stack on their local system or use the centrally maintained stacks on each HPC platform. For a detailed description of installation options, see :ref:`Installing the HPC-Stack <InstallBuildHPCstack>`.  

Disclaimer
---------------

The United States Department of Commerce (DOC) GitHub project code is provided on an "as is" basis and the user assumes responsibility for its use. DOC has relinquished control of the information and no longer has responsibility to protect the integrity, confidentiality, or availability of the information. Any claims against the Department of Commerce stemming from the use of its GitHub project will be governed by all applicable Federal law. Any reference to specific commercial products, processes, or services by service mark, trademark, manufacturer, or otherwise, does not constitute or imply their endorsement, recommendation or favoring by the Department of Commerce. The Department of Commerce seal and logo, or the seal and logo of a DOC bureau, shall not be used in any manner to imply endorsement of any commercial product or activity by DOC or the United States Government.





