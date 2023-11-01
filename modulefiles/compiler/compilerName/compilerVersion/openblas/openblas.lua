help([[OpenBLAS is an optimized Basic Linear Algebra Subprograms (BLAS) 
library based on GotoBLAS2 1.13 BSD version.
Software website - http://www.openblas.net/ ]])

local pkgName = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

local hierA = hierarchyA(pkgNameVer,1)
local compNameVer = hierA[1]
local compNameVerD = compNameVer:gsub("/","-")

conflict(pkgName)

-- Set prerequisites and conflicts
conflict("mkl")

local opt = os.getenv("HPC_OPT") or os.getenv("OPT") or "/opt/modules"

local base = pathJoin(opt,compNameVerD,pkgName,pkgVersion)

local libpath  = pathJoin(base,"lib")             -- libraries
local incpath  = pathJoin(base,"include")         -- include files
local pkgpath  = pathJoin(libpath,"pkgconfig")       -- pc files
local libs     = "-lopenblas"

-- Update path variables in user environment
prepend_path("PKG_CONFIG_PATH", pkgpath)

-- Configure NCAR compiler wrappers to use headers and libraries
setenv("NCAR_ROOT_OPENBLAS", base)
setenv("NCAR_INC_OPENBLAS", incpath)
setenv("NCAR_LDFLAGS_OPENBLAS", libpath)
setenv("NCAR_LIBS_OPENBLAS", libs)
setenv("NCAR_ROOT_OPENBLAS", base)

setenv("OPENBLAS_VERSION", pkgVersion)
setenv("OPENBLAS_LIBS", libs)
setenv("OPENBLAS_ROOT", base)
setenv("OPENBLAS_INC", incpath)
prepend_path("PATH", pathJoin(base,"bin"))
prepend_path("MANPATH", pathJoin(base,"man"))
prepend_path("LIBRARY_PATH", libpath)
prepend_path("LD_LIBRARY_PATH", libpath) 
prepend_path("DYLD_LIBRARY_PATH", libpath) 
prepend_path("CPATH", pathJoin(base,"include"))

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: " .. pkgName .. " library")

