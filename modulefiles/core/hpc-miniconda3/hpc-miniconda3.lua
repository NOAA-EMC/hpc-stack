help([[
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

family("MetaPython")

conflict(pkgName)
conflict("hpc-python")
conflict("hpc-intelpython")

local miniconda3 = pathJoin("miniconda3",pkgVersion)
load(miniconda3)
prereq(miniconda3)

local opt = os.getenv("HPC_OPT") or os.getenv("OPT") or "/opt/modules"
local mpath = pathJoin(opt,"modulefiles/core","miniconda3",pkgVersion)
prepend_path("MODULEPATH", mpath)

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: Python")
whatis("Description: Miniconda Family and module access")
