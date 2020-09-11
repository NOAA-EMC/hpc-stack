help([[
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

conflict(pkgName)

local base = pathJoin("/opt/intel", "compilers_and_libraries_" .. pkgVersion, "mac")

setenv("MKLROOT", pathJoin(base,"mkl"))
setenv("MKL_ROOT", pathJoin(base,"mkl"))
setenv("NLSPATH", pathJoin(base,"mkl/lib/locale/%l_%t/%N"))

prepend_path("CPATH",  pathJoin(base,"mkl/include"))

prepend_path("LIBRARY_PATH", pathJoin(base,"tbb/lib"))
prepend_path("LIBRARY_PATH", pathJoin(base,"compiler/lib"))
prepend_path("LIBRARY_PATH", pathJoin(base,"mkl/lib"))

prepend_path("LD_LIBRARY_PATH", pathJoin(base,"tbb/lib"))
prepend_path("LD_LIBRARY_PATH", pathJoin(base,"compiler/lib"))
prepend_path("LD_LIBRARY_PATH", pathJoin(base,"mkl/lib"))

prepend_path("DYLD_LIBRARY_PATH", pathJoin(base,"tbb/lib"))
prepend_path("DYLD_LIBRARY_PATH", pathJoin(base,"compiler/lib"))
prepend_path("DYLD_LIBRARY_PATH", pathJoin(base,"mkl/lib"))

prepend_path("PKG_CONFIG_PATH", pathJoin(base,"mkl/bin/pkgconfig"))

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: Library")
whatis("Description: Intel Math Kernal Library")
