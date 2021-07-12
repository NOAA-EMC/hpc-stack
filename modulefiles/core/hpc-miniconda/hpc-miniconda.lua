help([[
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

family("MetaPython")

conflict(pkgName)
conflict("hpc-python")
conflict("hpc-intelpython")
conflict("hpc-cray-python")

local python = pathJoin("miniconda",pkgVersion)
load(python)
prereq(python)

local opt = os.getenv("HPC_OPT") or os.getenv("OPT") or "/opt/modules"
local mpath = pathJoin(opt,"modulefiles/python","miniconda",pkgVersion)
prepend_path("MODULEPATH", mpath)

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: Python")
whatis("Description: Miniconda3 Family and module access")
