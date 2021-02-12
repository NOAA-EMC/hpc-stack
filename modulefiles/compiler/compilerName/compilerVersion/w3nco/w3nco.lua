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

setenv("w3nco_ROOT", base)
setenv("w3nco_VERSION", pkgVersion)
setenv("W3NCO_INC4", pathJoin(base,"include_4"))
setenv("W3NCO_INC8", pathJoin(base,"include_8"))
setenv("W3NCO_INCd", pathJoin(base,"include_d"))
setenv("W3NCO_LIB4", pathJoin(base,"lib/libw3nco_4.a"))
setenv("W3NCO_LIB8", pathJoin(base,"lib/libw3nco_8.a"))
setenv("W3NCO_LIBd", pathJoin(base,"lib/libw3nco_d.a"))

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: " .. pkgName .. " library")
