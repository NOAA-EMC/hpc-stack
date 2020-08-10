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

setenv("sp_ROOT", base)
setenv("sp_VERSION", pkgVersion)
setenv("SP_INC4", pathJoin(base,"include_4"))
setenv("SP_INC8", pathJoin(base,"include_8"))
setenv("SP_INCd", pathJoin(base,"include_d"))
setenv("SP_LIB4", pathJoin(base,"lib/libsp_4.a"))
setenv("SP_LIB8", pathJoin(base,"lib/libsp_8.a"))
setenv("SP_LIBd", pathJoin(base,"lib/libsp_d.a"))

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: " .. pkgName .. " library")
