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

setenv("bacio_ROOT", base)
setenv("bacio_VERSION", pkgVersion)
setenv("BACIO_INC4", pathJoin(base,"include_4"))
setenv("BACIO_INC8", pathJoin(base,"include_8"))
setenv("BACIO_LIB4", pathJoin(base,"lib/libbacio_4.a"))
setenv("BACIO_LIB8", pathJoin(base,"lib/libbacio_8.a"))

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: " .. pkgName .. " library")
