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

prepend_path("LD_LIBRARY_PATH", pathJoin(base,"${CMAKE_INSTALL_LIBDIR}"))
prepend_path("DYLD_LIBRARY_PATH", pathJoin(base,"${CMAKE_INSTALL_LIBDIR}"))

prepend_path("CPATH", pathJoin(base,"include"))
prepend_path("MANPATH", pathJoin(base,"share","man"))

setenv("Jasper_ROOT", base)
setenv("JASPER_ROOT", base)
setenv("JASPER_LIB", pathJoin(base,"${CMAKE_INSTALL_LIBDIR}","libjasper.a"))
setenv("JASPER_INCLUDES", pathJoin(base,"include"))
setenv("JASPER_LIBRARIES", pathJoin(base,"${CMAKE_INSTALL_LIBDIR}"))
setenv("JASPER_VERSION", pkgVersion)

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: Jasper library")
