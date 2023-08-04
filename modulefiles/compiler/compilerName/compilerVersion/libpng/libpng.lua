help([[
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

local hierA        = hierarchyA(pkgNameVer,1)
local compNameVer  = hierA[1]
local compNameVerD = compNameVer:gsub("/","-")

conflict(pkgName)

local opt = os.getenv("HPC_OPT") or os.getenv("OPT") or "/opt/modules"

local base = pathJoin(opt,compNameVerD,pkgName,pkgVersion)

local libdir = "lib"
if (isFile(pathJoin(base,"lib64","libpng.a"))) then
  libdir = "lib64"
end

prepend_path("LD_LIBRARY_PATH", pathJoin(base,libdir))
prepend_path("DYLD_LIBRARY_PATH", pathJoin(base,libdir))
prepend_path("CPATH", pathJoin(base,"include"))
prepend_path("MANPATH", pathJoin(base,"share","man"))

setenv("PNG_ROOT", base)
setenv("LIBPNG_LIB", pathJoin(base,libdir,"libpng.a"))
setenv("PNG_INCLUDES", pathJoin(base,"include"))
setenv("PNG_LIBRARIES", pathJoin(base,libdir))
setenv("PNG_VERSION", pkgVersion)

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: PNG library")
