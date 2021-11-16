help([[
]])

local pkgName = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

local hierA        = hierarchyA(pkgNameVer,1)
local compNameVer  = hierA[1]
local compNameVerD = compNameVer:gsub("/","-")

conflict(pkgName)

load("bacio", "w3emc")
prereq("bacio", "w3emc")

local opt = os.getenv("HPC_OPT") or os.getenv("OPT") or "/opt/modules"

local base = pathJoin(opt,compNameVerD,pkgName,pkgVersion)

setenv("nemsio_ROOT", base)
setenv("nemsio_VERSION", pkgVersion)
setenv("NEMSIO_INC", pathJoin(base,"include"))
setenv("NEMSIO_LIB", pathJoin(base,"lib/libnemsio.a"))
prepend_path("PATH", pathJoin(base,"bin"))

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: " .. pkgName .. " library")

