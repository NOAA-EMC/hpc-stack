help([[
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

family("MetaCompiler")

conflict(pkgName)
conflict("hpc-gnu", "hpc-gcc")

local compiler = pathJoin("intel",pkgVersion)
load(compiler)
prereq(compiler)
try_load("mkl")

local opt = os.getenv("HPC_OPT") or os.getenv("OPT") or "/opt/modules"
local mpath = pathJoin(opt,"modulefiles/compiler","cray-intel",pkgVersion)
prepend_path("MODULEPATH", mpath)

setenv("FC",  "ftn")
setenv("CC",  "cc")
setenv("CXX", "CC")

setenv("SERIAL_FC",  "ftn")
setenv("SERIAL_CC",  "cc")
setenv("SERIAL_CXX", "CC")

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: Compiler")
whatis("Description: Intel Compiler Family and module access")
