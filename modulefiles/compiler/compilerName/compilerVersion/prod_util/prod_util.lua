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

setenv("prod_util_ROOT", base)
prepend_path("PATH", pathJoin(base, "bin"))

setenv("UTILROOT", base)
setenv("MDATE", pathJoin(base, "bin", "mdate"))
setenv("NDATE", pathJoin(base, "bin", "ndate"))
setenv("NHOUR", pathJoin(base, "bin", "nhour"))
setenv("FSYNC", pathJoin(base, "bin", "fsync_file"))

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: Utility")
whatis("Description: " .. pkgName .. " utility")
