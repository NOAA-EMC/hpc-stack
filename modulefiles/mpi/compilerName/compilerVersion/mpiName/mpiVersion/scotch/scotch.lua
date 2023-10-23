help([[Scotch is a software package for graph and mesh/hypergraph partitioning,
graph clustering, and sparse matrix ordering.]])

local pkgName = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

local hierA        = hierarchyA(pkgNameVer,2)
local mpiNameVer   = hierA[1]
local compNameVer  = hierA[2]
local mpiNameVerD  = mpiNameVer:gsub("/","-")
local compNameVerD = compNameVer:gsub("/","-")

conflict(pkgName)

depends_on("zlib")

local opt = os.getenv("HPC_OPT") or os.getenv("OPT") or "/opt/modules"

local base = pathJoin(opt,compNameVerD,mpiNameVerD,pkgName,pkgVersion)

prepend_path("PATH", pathJoin(base,"bin"))
prepend_path("MANPATH", pathJoin(base,"man"))
prepend_path("LIBRARY_PATH", pathJoin(base,"lib"))
prepend_path("LD_LIBRARY_PATH", pathJoin(base,"lib"))
prepend_path("DYLD_LIBRARY_PATH", pathJoin(base,"lib"))
prepend_path("CPATH", pathJoin(base,"include"))
prepend_path("CMAKE_PREFIX_PATH", base)

setenv("scotch_ROOT", base)
setenv("scotch_VERSION", pkgVersion)

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: " .. pkgName .. " library")
