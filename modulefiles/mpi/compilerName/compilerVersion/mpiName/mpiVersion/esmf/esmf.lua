help([[
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

local hierA        = hierarchyA(pkgNameVer,2)
local mpiNameVer   = hierA[1]
local compNameVer  = hierA[2]
local mpiNameVerD  = mpiNameVer:gsub("/","-")
local compNameVerD = compNameVer:gsub("/","-")

conflict(pkgName)

local opt = os.getenv("HPC_OPT") or os.getenv("OPT") or "/opt/modules"

local base = pathJoin(opt,compNameVerD,mpiNameVerD,pkgName,pkgVersion)

prepend_path("PATH", pathJoin(base,"bin"))
prepend_path("LD_LIBRARY_PATH", pathJoin(base,"lib"))
prepend_path("DYLD_LIBRARY_PATH", pathJoin(base,"lib"))
prepend_path("LIBRARY_PATH", pathJoin(base,"lib"))
prepend_path("MANPATH", pathJoin(base,"share","man"))
prepend_path("CPATH", pathJoin(base,"include"))

setenv( "ESMF_ROOT", base)
setenv( "ESMF_DIR", base)
setenv( "ESMF_PATH", base)
setenv( "ESMF_BIN", pathJoin(base,"bin") )
setenv( "ESMF_INC", pathJoin(base,"include") )
setenv( "ESMF_INCLUDES", pathJoin(base,"include") )
setenv( "ESMF_LIB", pathJoin(base,"lib") )
setenv( "ESMF_LIBRARIES", pathJoin(base,"lib") )
setenv( "ESMF_VERSION", pkgVersion)
setenv( "ESMF_MOD", pathJoin(base,"mod") )
setenv( "ESMFMKFILE", pathJoin(base,"lib/esmf.mk") )

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: ESMF library")
