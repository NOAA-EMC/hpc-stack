help([[
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

family("MetaCompiler")

conflict(pkgName)
conflict("hpc-intel")

local compiler = pathJoin("gcc",pkgVersion)
load(compiler)
prereq(compiler)

local opt = os.getenv("HPC_OPT") or os.getenv("OPT") or "/opt/modules"
local mpath = pathJoin(opt,"modulefiles/compiler","gcc",pkgVersion)
prepend_path("MODULEPATH", mpath)

setenv("FC",  "gfortran")
setenv("CC",  "gcc")
setenv("CXX", "g++")

setenv("SERIAL_FC",  "gfortran")
setenv("SERIAL_CC",  "gcc")
setenv("SERIAL_CXX", "g++")

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: Compiler")
whatis("Description: GNU Compiler Family and module access")
