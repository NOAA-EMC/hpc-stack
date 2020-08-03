help([[
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

local hierA        = hierarchyA(pkgNameVer,1)
local compNameVer  = hierA[1]
local compNameVerD = compNameVer:gsub("/","-")

family("mpi")

conflict(pkgName)
conflict("mpich","impi")

try_load("szip")

local opt = os.getenv("HPC_OPT") or os.getenv("OPT") or "/opt/modules"

local mpath = pathJoin(opt,"modulefiles/mpi",compNameVer,pkgName,pkgVersion)
prepend_path("MODULEPATH", mpath)

local base = pathJoin(opt,compNameVerD,pkgName,pkgVersion)

prepend_path("PATH", pathJoin(base,"bin"))
prepend_path("LD_LIBRARY_PATH", pathJoin(base,"lib"))
prepend_path("DYLD_LIBRARY_PATH", pathJoin(base,"lib"))
prepend_path("CPATH", pathJoin(base,"include"))
prepend_path("MANPATH", pathJoin(base,"share","man"))

setenv("MPI_ROOT", base)

-- Enable FindMPI.cmake to automatically find and configure OpenMPI
setenv("MPI_HOME", base)
setenv("MPI_Fortran_COMPILER", pathJoin(base,"bin/mpifort"))
setenv("MPI_C_COMPILER", pathJoin(base,"bin/mpicc"))
setenv("MPI_CXX_COMPILER", pathJoin(base,"bin/mpicxx"))

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: OpenMPI library")
