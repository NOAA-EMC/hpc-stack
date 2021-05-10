help([[
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

family("MetaPython")

conflict(pkgName)
conflict("hpc-conda")
conflict("hpc-intelpython")

local python = pathJoin("python",pkgVersion)
load(python)
prereq(python)

local opt = os.getenv("HPC_OPT") or os.getenv("OPT") or "/opt/modules"
local mpath = pathJoin(opt,"modulefiles/core","python",pkgVersion)
prepend_path("MODULEPATH", mpath)

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: Python")
whatis("Description: Python Family and module access")
