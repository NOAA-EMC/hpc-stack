help([[
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

conflict(pkgName)

prereq("boost-headers")

local opt = os.getenv("OPT") or "/opt/modules"

local base = pathJoin(opt,"core",pkgName,pkgVersion)

prepend_path("CPATH", pathJoin(base,"include"))
prepend_path("MANPATH", pathJoin(base,"share","man"))

setenv("CGAL_ROOT", base)
setenv("CGAL_PATH", base)
setenv("CGAL_DIR", base)
setenv("CGAL_INCLUDE_DIRS", pathJoin(base,"include"))
setenv("CGAL_LIBRARIES", pathJoin(base,"lib"))
setenv("CGAL_VERSION", pkgVersion)

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: CGAL library")
