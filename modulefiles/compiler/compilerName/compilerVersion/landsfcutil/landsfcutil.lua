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

setenv("landsfcutil_ROOT", base)
setenv("landsfcutil_VERSION", pkgVersion)
setenv("LANDSFCUTIL_INC4", pathJoin(base,"include_4"))
setenv("LANDSFCUTIL_INCd", pathJoin(base,"include_d"))
setenv("LANDSFCUTIL_LIB4", pathJoin(base,"lib/liblandsfcutil_4.a"))
setenv("LANDSFCUTIL_LIBd", pathJoin(base,"lib/liblandsfcutil_d.a"))

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: " .. pkgName .. " library")
