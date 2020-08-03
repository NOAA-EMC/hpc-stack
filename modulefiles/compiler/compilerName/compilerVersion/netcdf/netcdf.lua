help([[
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

local hierA        = hierarchyA(pkgNameVer,1)
local compNameVer  = hierA[1]
local compNameVerD = compNameVer:gsub("/","-")

conflict(pkgName)

always_load("hdf5")
prereq("hdf5")

local opt = os.getenv("HPC_OPT") or os.getenv("OPT") or "/opt/modules"

local base = pathJoin(opt,compNameVerD,pkgName,pkgVersion)

prepend_path("PATH", pathJoin(base,"bin"))
prepend_path("LD_LIBRARY_PATH", pathJoin(base,"lib"))
prepend_path("DYLD_LIBRARY_PATH", pathJoin(base,"lib"))
prepend_path("CPATH", pathJoin(base,"include"))
prepend_path("MANPATH", pathJoin(base,"share","man"))

setenv("NetCDF", base)
setenv("NetCDF_ROOT", base)
setenv("NetCDF_INCLUDES", pathJoin(base,"include"))
setenv("NetCDF_LIBRARIES", pathJoin(base,"lib"))
setenv("NetCDF_VERSION", pkgVersion)

setenv("NETCDF", base)
setenv("NETCDF_ROOT", base)
setenv("NETCDF_INCLUDES", pathJoin(base,"include"))
setenv("NETCDF_LIBRARIES", pathJoin(base,"lib"))
setenv("NETCDF_VERSION", pkgVersion)

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: NetCDF4 C, CXX and Fortran library")
