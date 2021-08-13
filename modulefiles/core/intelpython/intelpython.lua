help([[
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

family("python")

conflict(pkgName)
conflict("miniconda3")
conflict("python")

local opt = os.getenv("HPC_OPT") or os.getenv("OPT") or "/opt/modules"

local mpath = pathJoin(opt,"modulefiles/core",pkgName,pkgVersion)
prepend_path("MODULEPATH", mpath)

local base = pathJoin(opt,pkgName,pkgVersion)

prepend_path("PATH", pathJoin(base,"bin"))
prepend_path("PYTHONPATH", pathJoin(base,"lib/python@PYTHON_VERSION@/site-packages"))

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: Python")
whatis("Description: Intel Python Family")
