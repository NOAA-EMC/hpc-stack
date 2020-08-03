help([[
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

local hierA        = hierarchyA(pkgNameVer,1)
local compNameVer  = hierA[1]
local compNameVerD = compNameVer:gsub("/","-")

conflict(pkgName)

local opt = os.getenv("HPC_OPT") or os.getenv("OPT") or "/opt/modules"

local base = pathJoin(opt,compNameVerD,pkgName,pkgVersion)

prepend_path("LD_LIBRARY_PATH", pathJoin(base,"lib"))
prepend_path("DYLD_LIBRARY_PATH", pathJoin(base,"lib"))
prepend_path("LIBRARY_PATH", pathJoin(base,"lib"))

setenv("TAU_ROOT", base)
setenv("TAU_PATH", base)
setenv("TAU_INCLUDES", pathJoin(base,"x86_64/include"))
setenv("TAU_LIBRARIES", pathJoin(base,"x86_64/lib"))
setenv("TAU_MAKEFILE", pathJoin(base,"x86_64","lib","Makefile.tau-ompt-tr4-mpi-pdt-openmp"))
setenv("TAU_VERSION", pkgVersion)

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: TAU (Tuning and Analysis Utilities) Version 2 library")
