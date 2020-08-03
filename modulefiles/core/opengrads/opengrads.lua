help([[
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

conflict(pkgName)

local opt = os.getenv("HPC_OPT") or os.getenv("OPT") or "/opt/modules"

local base = pathJoin(opt,pkgName,pkgVersion)

prepend_path("PATH", pathJoin(base,"Contents"))

prepend_path("GADDIR", pathJoin(base,"Contents/Resources/SupportData"))
prepend_path("GASCRP", pathJoin(base,"Contents/Resources/Scripts"))

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: Software")
whatis("Description: OpenGrADS")
