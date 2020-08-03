help([[
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

family("compiler")

conflict(pkgName)
conflict("intel")

local opt = os.getenv("HPC_OPT") or os.getenv("OPT") or "/opt/modules"

local mpath = pathJoin(opt,"modulefiles/compiler",pkgName,pkgVersion)
prepend_path("MODULEPATH", mpath)

local base = pathJoin(opt,pkgName,pkgVersion)

prepend_path("PATH", pathJoin(base,"bin"))
prepend_path("LIBRARY_PATH", pathJoin(base,"lib"))
prepend_path("LD_LIBRARY_PATH", pathJoin(base,"lib"))
prepend_path("DYLD_LIBRARY_PATH", pathJoin(base,"lib"))
prepend_path("INCLUDE",  pathJoin(base,"include"))
prepend_path("CPATH",  pathJoin(base,"include"))
prepend_path("MANPATH",  pathJoin(base,"share","man"))

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: Compiler")
whatis("Description: GNU Compiler Family")
