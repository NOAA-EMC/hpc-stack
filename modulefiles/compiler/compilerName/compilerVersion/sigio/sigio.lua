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

setenv("sigio_ROOT", base)
setenv("sigio_VERSION", pkgVersion)
setenv("SIGIO_INC", pathJoin(base,"include"))
setenv("SIGIO_LIB", pathJoin(base,"lib/libsigio.a"))

setenv("SIGIO_INC4", pathJoin(base,"include"))
setenv("SIGIO_LIB4", pathJoin(base,"lib/libsigio.a"))

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: " .. pkgName .. " library")
