help([[
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

local hierA        = hierarchyA(pkgNameVer,1)
local compNameVer  = hierA[1]
local compNameVerD = compNameVer:gsub("/","-")

conflict(pkgName)

local opt = os.getenv("HPC_OPT") or os.getenv("OPT") or "/opt/modules"

local base = pathJoin(opt,compNameVerD,pkgName,pkgVersion)

prepend_path("PATH", pathJoin(base,"bin"))
prepend_path("LD_LIBRARY_PATH", pathJoin(base,"${CMAKE_INSTALL_LIBDIR}"))
prepend_path("DYLD_LIBRARY_PATH", pathJoin(base,"${CMAKE_INSTALL_LIBDIR}"))
prepend_path("CPATH", pathJoin(base,"include"))
prepend_path("MANPATH", pathJoin(base,"share","man"))

setenv("GEOS_ROOT", base)
setenv("GEOS_DIR", pathJoin(base,"${CMAKE_INSTALL_LIBDIR}","cmake",pkgName))
setenv("GEOS_VERSION", pkgVersion)

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: GEOS (Geometry Engine – Open Source) is a C++ port of the Java Topology Suite")
