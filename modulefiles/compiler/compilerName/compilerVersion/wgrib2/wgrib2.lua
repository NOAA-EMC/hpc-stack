help([[
]])

local pkgName = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

local hierA        = hierarchyA(pkgNameVer,1)
local compNameVer  = hierA[1]
local compNameVerD = compNameVer:gsub("/","-")

conflict(pkgName)

local opt = os.getenv("HPC_OPT") or os.getenv("OPT") or "/opt/modules"

local base = pathJoin(opt,compNameVerD,pkgName,pkgVersion)

prepend_path("PATH", pathJoin(base,"bin"))
setenv("wgrib2_ROOT", base)
setenv("wgrib2_VERSION", pkgVersion)
setenv("WGRIB2_INC", pathJoin(base,"include"))
setenv("WGRIB2_LIB", pathJoin(base,"lib","libwgrib2.a"))
setenv("WGRIB2", pathJoin(base,"bin", "wgrib2"))

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: " .. pkgName .. " library")
