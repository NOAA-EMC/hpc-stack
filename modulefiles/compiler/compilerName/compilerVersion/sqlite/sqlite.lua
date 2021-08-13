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

setenv("SQLITE_ROOT", base)
setenv("SQLITE_VERSION", pkgVersion)

prepend_path("PKG_CONFIG_PATH", pathJoin(base,"${CMAKE_INSTALL_LIBDIR}","pkgconfig"))

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: SQLite is a C-language library that implements a small, fast, self-contained, high-reliability, full-featured, SQL database engine")
