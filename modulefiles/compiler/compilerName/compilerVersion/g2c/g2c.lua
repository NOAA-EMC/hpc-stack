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

setenv("g2c_ROOT", base)
setenv("g2c_VERSION", pkgVersion)
setenv("G2C_INC", pathJoin(base,"include"))
setenv("G2C_LIB", pathJoin(base,"lib/libg2c.a"))

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: " .. pkgName .. " library")
