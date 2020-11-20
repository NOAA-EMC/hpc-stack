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

setenv("upp_ROOT", base)
setenv("upp_VERSION", pkgVersion)
setenv("NCEPPOST_INC", pathJoin(base,"include"))
setenv("NCEPPOST_LIB", pathJoin(base,"lib/libupp.a"))
setenv("POST_INC", pathJoin(base,"include"))
setenv("POST_LIB", pathJoin(base,"lib/libupp.a"))
setenv("UPP_INC", pathJoin(base,"include"))
setenv("UPP_LIB", pathJoin(base,"lib/libupp.a"))

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: " .. pkgName .. " library")
