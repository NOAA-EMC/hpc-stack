help([[
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

family("MetaCompiler")

conflict(pkgName)
conflict("hpc-gnu")

local compiler = pathJoin("intel",pkgVersion)
load(compiler)
prereq(compiler)
try_load("mkl")

local opt = os.getenv("HPC_OPT") or os.getenv("OPT") or "/opt/modules"
setenv("HPC_OPT", opt)

local mpath = pathJoin(opt,"modulefiles/compiler","intel",pkgVersion)
prepend_path("MODULEPATH", mpath)

setenv("FC",  "ifort")
setenv("CC",  "icc")
setenv("CXX", "icpc")

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: Compiler")
whatis("Description: Intel Compiler Family and module access")
