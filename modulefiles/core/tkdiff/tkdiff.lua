help([[
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

conflict(pkgName)

local opt = os.getenv("HPC_OPT") or os.getenv("OPT") or "/opt/modules"

local base = pathJoin(opt,"core",pkgName,pkgVersion)

prepend_path("PATH", pathJoin(base,"bin"))

setenv("TKDIFF_PATH",base)

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: Software")
whatis("Description: tkdiff diff viewer")
