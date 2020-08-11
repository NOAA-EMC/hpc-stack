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

load("bacio", "g2", "g2tmpl", "ip", "sp", "w3nco", "w3emc", "crtm")
prereq("bacio", "g2", "g2tmpl", "ip", "sp", "w3nco", "w3emc", "crtm")

local opt = os.getenv("HPC_OPT") or os.getenv("OPT") or "/opt/modules"

local base = pathJoin(opt,compNameVerD,mpiNameVerD,pkgName,pkgVersion)

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
