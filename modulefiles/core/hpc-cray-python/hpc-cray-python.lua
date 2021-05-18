help([[
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

family("MetaPython")

conflict(pkgName)
conflict("hpc-miniconda3")
conflict("hpc-intelpython")
conflict("hpc-python")

local python = pathJoin("cray-python",pkgVersion)
load(python)
prereq(python)

local opt = os.getenv("HPC_OPT") or os.getenv("OPT") or "/opt/modules" or "/opt"
local mpath = pathJoin(opt,"modulefiles","cray-python",pkgVersion)
prepend_path("MODULEPATH", mpath)

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: Python")
whatis("Description: Cray Python Family and module access")
