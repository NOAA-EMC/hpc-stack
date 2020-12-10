help([[
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

local hierA        = hierarchyA(pkgNameVer,1)
local compNameVer  = hierA[1]
local compNameVerD = compNameVer:gsub("/","-")

conflict(pkgName)

always_load("netcdf")
prereq("netcdf")

local opt = os.getenv("HPC_OPT") or os.getenv("OPT") or "/opt/modules"

local base = pathJoin(opt,compNameVerD,pkgName,pkgVersion)

prepend_path("PATH", pathJoin(base,"bin"))
setenv("CDO_ROOT", base)
setenv("CDO_VERSION", pkgVersion)

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: Utility")
whatis("Description: Climate Data Operators (CDO) Utility")
