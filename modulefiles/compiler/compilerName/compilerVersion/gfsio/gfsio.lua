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

setenv("gfsio_ROOT", base)
setenv("gfsio_VERSION", pkgVersion)

setenv("GFSIO_INC",  pathJoin(base,"include"))
setenv("GFSIO_LIB",  pathJoin(base,"lib/libgfsio.a"))

setenv("GFSIO_INC4",  pathJoin(base,"include"))
setenv("GFSIO_LIB4",  pathJoin(base,"lib/libgfsio.a"))

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: " .. pkgName .. " library")
