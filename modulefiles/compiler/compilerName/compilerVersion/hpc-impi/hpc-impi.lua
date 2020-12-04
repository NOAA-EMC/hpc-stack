help([[
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

local hierA        = hierarchyA(pkgNameVer,1)
local compNameVer  = hierA[1]
local compNameVerD = compNameVer:gsub("/","-")

conflict(pkgName)
conflict("hpc-cray-mpich","hpc-mpich","hpc-mpt","hpc-openmpi")

local mpi = pathJoin("impi",pkgVersion)
load(mpi)
prereq(mpi)

local opt = os.getenv("HPC_OPT") or os.getenv("OPT") or "/opt/modules"
local mpath = pathJoin(opt,"modulefiles/mpi",compNameVer,"impi",pkgVersion)
prepend_path("MODULEPATH", mpath)

setenv("MPI_FC",  "mpiifort")
setenv("MPI_CC",  "mpiicc")
setenv("MPI_CXX", "mpiicpc")

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: Intel MPI library and module access")
