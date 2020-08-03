help([[
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

local hierA        = hierarchyA(pkgNameVer,1)
local compNameVer  = hierA[1]
local compNameVerD = compNameVer:gsub("/","-")

--io.stderr:write("compNameVer: ",compNameVer,"\n")
--io.stderr:write("compNameVerD: ",compNameVerD,"\n")

conflict(pkgName)
conflict("hpc-openmpi","hpc-mpich","hpc-impi")

local mpi = pathJoin("mpt",pkgVersion)
load(mpi)
prereq(mpi)

local opt = os.getenv("HPC_OPT") or os.getenv("OPT") or "/opt/modules"
local mpath = pathJoin(opt,"modulefiles/mpi",compNameVer,"mpt",pkgVersion)
prepend_path("MODULEPATH", mpath)

setenv("MPI_FC",  "mpif90")
setenv("MPI_CC",  "mpicc")
setenv("MPI_CXX", "mpicxx")

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: SGI MPT library and module access")
