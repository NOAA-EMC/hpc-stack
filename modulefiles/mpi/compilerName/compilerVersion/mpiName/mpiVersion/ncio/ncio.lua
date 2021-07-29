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
load("netcdf")
prereq("netcdf")

local opt = os.getenv("HPC_OPT") or os.getenv("OPT") or "/opt/modules"

local base = pathJoin(opt,compNameVerD,mpiNameVerD,pkgName,pkgVersion)

setenv("ncio_ROOT", base)
setenv("ncio_VERSION", pkgVersion)

setenv("NCIO_INC", pathJoin(base,"include"))
setenv("NCIO_LIB", pathJoin(base,"${CMAKE_INSTALL_LIBDIR}","libncio.a"))
setenv("NCIO_LIBDIR", pathJoin(base, "${CMAKE_INSTALL_LIBDIR}"))

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: " .. pkgName .. " library")
