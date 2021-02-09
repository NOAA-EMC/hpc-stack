help([[
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

local hierA        = hierarchyA(pkgNameVer,1)
local compNameVer  = hierA[1]
local compNameVerD = compNameVer:gsub("/","-")

conflict(pkgName)

always_load("ips")
always_load("python/3.6.3")
always_load("nco")
always_load("grib_util")
always_load("met")
prereq("ips")
prereq("python/3.6.3")
prereq("nco")
prereq("grib_util")
prereq("met")


local opt = os.getenv("HPC_OPT") or os.getenv("OPT") or "/opt/modules"

local base = pathJoin(opt,compNameVerD,pkgName,pkgVersion)

prepend_path("PATH", pathJoin(base,"ush"))

setenv("METPLUS_ROOT", base)
setenv("METPLUS_VERSION", pkgVersion)
setenv("METPLUS_PATH", base)

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: application")
whatis("Description: Model Evaluation Tools Plus (METplus)")
