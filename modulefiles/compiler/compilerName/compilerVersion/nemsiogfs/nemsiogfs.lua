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

setenv("nemsiogfs_ROOT", base)
setenv("nemsiogfs_VERSION", pkgVersion)
setenv("NEMSIOGFS_INC", pathJoin(base,"include"))
setenv("NEMSIOGFS_LIB", pathJoin(base,"lib/libnemsiogfs.a"))

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: " .. pkgName .. " library")
