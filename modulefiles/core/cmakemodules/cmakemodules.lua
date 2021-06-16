help([[
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

conflict(pkgName)

local opt = os.getenv("HPC_OPT") or os.getenv("OPT") or "/opt/modules"

local base = pathJoin(opt,"core",pkgName,pkgVersion)

prepend_path("CMAKE_MODULE_PATH", pathJoin(base,"Modules"), ";")

setenv("cmakemodules_ROOT", base)

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: Software")
whatis("Description: CMakeModules (A collection of ECMWF CMake modules)")
