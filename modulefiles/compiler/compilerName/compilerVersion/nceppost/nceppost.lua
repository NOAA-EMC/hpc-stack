help([[
]])

local pkgName = myModuleName()
local pkgVersion = myModuleVersion()

local hierA        = hierarchyA(pkgNameVer,1)
local compNameVer  = hierA[1]
local compNameVerD = compNameVer:gsub("/","-")

conflict(pkgName)

local opt = os.getenv("HPC_OPT") or os.getenv("OPT") or "/opt/modules"

local base = pathJoin(opt,compNameVerD,pkgName,pkgVersion)

setenv("nceppost_ROOT", base)
setenv("nceppost_VERSION", pkgVersion)
setenv("NCEPPOST_INC", pathJoin(base,"include"))
setenv("NCEPPOST_LIB", pathJoin(base,"lib/libnceppost.a"))
setenv("POST_INC", pathJoin(base,"include"))
setenv("POST_LIB", pathJoin(base,"lib/libnceppost.a"))

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: " .. pkgName .. " library")
