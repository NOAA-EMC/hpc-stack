help([[
]])

local pkgName = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

local hierA        = hierarchyA(pkgNameVer,2)
local mpiNameVer   = hierA[1]
local compNameVer  = hierA[2]
local mpiNameVerD  = mpiNameVer:gsub("/","-")
local compNameVerD = compNameVer:gsub("/","-")

conflict(pkgName)

load("netcdf")
prereq("netcdf")

local opt = os.getenv("HPC_OPT") or os.getenv("OPT") or "/opt/modules"

local base = pathJoin(opt,compNameVerD,mpiNameVerD,pkgName,pkgVersion)

prepend_path("PATH", pathJoin(base,"bin"))
setenv("wgrib2_ROOT", base)
setenv("wgrib2_VERSION", pkgVersion)
setenv("WGRIB2_INC", pathJoin(base,"include"))
setenv("WGRIB_LIB", pathJoin(base,"${CMAKE_INSTALL_LIBDIR}/libwgrib2.a"))
setenv("WGRIB2_LIBAPI", pathJoin(base,"${CMAKE_INSTALL_LIBDIR}/libwgrib2_api.a"))

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: " .. pkgName .. " library")
