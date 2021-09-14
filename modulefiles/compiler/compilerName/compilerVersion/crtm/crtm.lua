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

setenv("crtm_ROOT", base)
setenv("crtm_VERSION", pkgVersion)
setenv("CRTM_INC", pathJoin(base,"include"))
setenv("CRTM_LIB", pathJoin(base,"lib/libcrtm.a"))
setenv("CRTM_FIX", pathJoin(base,"fix"))

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: " .. pkgName .. " library")

