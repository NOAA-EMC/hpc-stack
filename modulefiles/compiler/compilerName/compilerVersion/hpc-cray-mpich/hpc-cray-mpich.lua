help([[
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

local hierA        = hierarchyA(pkgNameVer,1)
local compNameVer  = hierA[1]
local compNameVerD = compNameVer:gsub("/","-")

conflict(pkgName)
conflict("hpc-impi","hpc-mpich","hpc-mpt","hpc-openmpi")

local mpi = pathJoin("cray-mpich",pkgVersion)
load(mpi)
prereq(mpi)

local opt = os.getenv("HPC_OPT") or os.getenv("OPT") or "/opt/modules"
local mpath = pathJoin(opt,"modulefiles/mpi",compNameVer,"cray-mpich",pkgVersion)
prepend_path("MODULEPATH", mpath)

setenv("MPI_FC",  "ftn")
setenv("MPI_CC",  "cc")
setenv("MPI_CXX", "CC")

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: Cray MPICH Library and module access")
