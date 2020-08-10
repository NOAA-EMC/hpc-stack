help([[
]])

local pkgName = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

local hierA        = hierarchyA(pkgNameVer,2)
local mpiNameVer   = hierA[1]
local compNameVer  = hierA[2]
local mpiNameVerD  = mpiNameVer:gsub("/","-")
local compNameVerD = compNameVer:gsub("/","-")

conflict(pkgName)

load("sigio", "nemsio")
prereq("sigio", "nemsio")

local opt = os.getenv("HPC_OPT") or os.getenv("OPT") or "/opt/modules"

local base = pathJoin(opt,compNameVerD,mpiNameVerD,pkgName,pkgVersion)

setenv("w3emc_ROOT", base)
setenv("w3emc_VERSION", pkgVersion)
setenv("W3EMC_INC4", pathJoin(base,"include_4"))
setenv("W3EMC_INC8", pathJoin(base,"include_8"))
setenv("W3EMC_INCd", pathJoin(base,"include_d"))
setenv("W3EMC_LIB4", pathJoin(base,"lib/libw3emc_4.a"))
setenv("W3EMC_LIB8", pathJoin(base,"lib/libw3emc_8.a"))
setenv("W3EMC_LIBd", pathJoin(base,"lib/libw3emc_d.a"))

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: " .. pkgName .. " library")
