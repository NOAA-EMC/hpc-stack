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
always_load("netcdf")
prereq("hdf5")
prereq("netcdf")

local opt = os.getenv("HPC_OPT") or os.getenv("OPT") or "/opt/modules"

local base = pathJoin(opt,compNameVerD,pkgName,pkgVersion)

prepend_path("PATH", pathJoin(base,"bin/binO/Darwin.gfortran.64.mpiuni.default"))
prepend_path("LD_LIBRARY_PATH", pathJoin(base,"lib/libO/Darwin.gfortran.64.mpiuni.default"))
prepend_path("DYLD_LIBRARY_PATH", pathJoin(base,"lib/libO/Darwin.gfortran.64.mpiuni.default"))
prepend_path("CPATH", pathJoin(base,"include"))
prepend_path("CPATH", pathJoin(base,"mod/modO/Darwin.gfortran.64.mpiuni.default"))

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: ESMF library")
