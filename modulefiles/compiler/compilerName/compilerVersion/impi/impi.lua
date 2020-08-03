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

family("mpi")

conflict(pkgName)
conflict("mpich","openmpi")

always_load("intel/17.0.1")
prereq("intel/17.0.1")

try_load("szip")

local opt = os.getenv("HPC_OPT") or os.getenv("OPT") or "/opt/modules"
local base = "/opt/intel17/compilers_and_libraries_2017.1.132"

setenv("I_MPI_ROOT", pathJoin(base,"linux/mpi"))
setenv("MPI_ROOT", pathJoin(base,"linux/mpi"))

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: Intel MPI library")
