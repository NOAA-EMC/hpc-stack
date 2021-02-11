help([[
]])

local pkgName = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

local hierA        = hierarchyA(pkgNameVer,1)
local compNameVer  = hierA[1]
local compNameVerD = compNameVer:gsub("/","-")

load("sp")
prereq("sp")

conflict(pkgName)

local opt = os.getenv("HPC_OPT") or os.getenv("OPT") or "/opt/modules"

local base = pathJoin(opt,compNameVerD,pkgName,pkgVersion)

setenv("ip2_ROOT", base)
setenv("ip2_VERSION", pkgVersion)

setenv("IP2_INC4", pathJoin(base,"include_4"))
setenv("IP2_INC8", pathJoin(base,"include_8"))
setenv("IP2_INCd", pathJoin(base,"include_d"))
setenv("IP2_LIB4", pathJoin(base,"lib/libip2_4.a"))
setenv("IP2_LIB8", pathJoin(base,"lib/libip2_8.a"))
setenv("IP2_LIBd", pathJoin(base,"lib/libip2_d.a"))

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: " .. pkgName .. " library")
