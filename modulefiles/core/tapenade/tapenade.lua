help([[
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

conflict(pkgName)

local opt = os.getenv("HPC_OPT") or os.getenv("OPT") or "/opt/modules"

local base = pathJoin(opt,pkgName,pkgName .. pkgVersion)

prepend_path("PATH", pathJoin(base,"bin"))
prepend_path("CPATH", pathJoin(base,"include"))
prepend_path("MANPATH", pathJoin(base,"share","man"))

setenv("TAPENADE_HOME", base)
setenv("JAVA_HOME", pathJoin(opt,pkgName,"JAVA_HOME"))

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: Software")
whatis("Description: Tapenade - Automatic Differentiation Engine from INRIA")
