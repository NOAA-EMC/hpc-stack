help([[
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

conflict(pkgName)
conflict("boost")

local opt = os.getenv("HPC_OPT") or os.getenv("OPT") or "/opt/modules"

local base = pathJoin(opt,"core","boost",pkgVersion)

prepend_path("CPATH", pathJoin(base,"include"))

setenv( "BOOST_ROOT", base)
setenv( "BOOST_VERSION", pkgVersion)
setenv( "Boost_INCLUDE_DIR", pathJoin(base,"include"))

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: Boost C++ library (headers only)")
