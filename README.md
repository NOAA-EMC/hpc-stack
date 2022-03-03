
![Ubuntu](https://github.com/noaa-emc/hpc-stack/workflows/Build%20Ubuntu/badge.svg)
![macOS](https://github.com/noaa-emc/hpc-stack/workflows/Build%20macOS/badge.svg)

# hpc-stack

This repository provides a unified, shell script based build system
for building the software stack needed for the NOAA [Universal Forecast
System (UFS)](https://github.com/ufs-community/ufs-weather-model) and
related products, and applications written for the [Joint Effort for
Data assimilation Integration
(JEDI)](https://jointcenterforsatellitedataassimilation-jedi-docs.readthedocs-hosted.com/en/latest/)
framework.

This is part of the [NCEPLIBS](https://github.com/NOAA-EMC/NCEPLIBS) project.

## Authors

Rahul Mahajan, Kyle Gerheiser, Dusan Jovic, Hang-Lei, Dom Heinzeller

Code Manager: Kyle Gerheiser

Installers:

Machine     | Programmer
------------|------------------
Hera        | Kyle Gerheiser
Jet         | Kyle Gerheiser
Orion       | Hang-Lei
WCOSS-Dell  | Hang-Lei
WCOSS-Cray  | Hang-Lei
Cheyenne    | Dom Heinzeller
Gaea        | Dom Heinzeller

## Contributors

Mark Potts, Steve Lawrence, Ed Hartnett, Guoqing Ge, Raffaele Montuoro, David Huber

## Prerequisites:

The prerequisites of building hpc-stack are:

- [Lmod](https://lmod.readthedocs.io/en/latest/) - An Environment Module System
- CMake and make
- wget and curl
- git

Building the software stack is a **Three-Step process**, as described in the documentation:

- Step 1: Configure Build
- Step 2: Set Up Compiler, MPI, Python, and Module System
- Step 3: Build Software Stack


## Disclaimer

The United States Department of Commerce (DOC) GitHub project code is
provided on an "as is" basis and the user assumes responsibility for
its use. DOC has relinquished control of the information and no longer
has responsibility to protect the integrity, confidentiality, or
availability of the information. Any claims against the Department of
Commerce stemming from the use of its GitHub project will be governed
by all applicable Federal law. Any reference to specific commercial
products, processes, or services by service mark, trademark,
manufacturer, or otherwise, does not constitute or imply their
endorsement, recommendation or favoring by the Department of
Commerce. The Department of Commerce seal and logo, or the seal and
logo of a DOC bureau, shall not be used in any manner to imply
endorsement of any commercial product or activity by DOC or the United
States Government.
