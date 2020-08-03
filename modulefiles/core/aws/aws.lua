help([[
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

conflict(pkgName)

local opt = os.getenv("HPC_OPT") or os.getenv("OPT") or "/opt/modules"

local base = pathJoin(opt,pkgName)

prepend_path("PATH", pathJoin(base,"bin"))

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: Software")
whatis("Description: Amazon Web Services - Command Line Interface")
