help([[
]])

local pkgName = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

local hierA        = hierarchyA(pkgNameVer,1)
local compNameVer  = hierA[1]
local compNameVerD = compNameVer:gsub("/","-")

conflict(pkgName)

local opt = os.getenv("HPC_OPT") or os.getenv("OPT") or "/opt/modules"

local base = pathJoin(opt,compNameVerD,pkgName,pkgVersion)

setenv("bufr_ROOT", base)
setenv("bufr_VERSION", pkgVersion)
setenv("BUFR_INC4",    pathJoin(base,"include_4"))
setenv("BUFR_INC8",    pathJoin(base,"include_8"))
setenv("BUFR_INCd",    pathJoin(base,"include_d"))
setenv("BUFR_LIB4",    pathJoin(base,"${CMAKE_INSTALL_LIBDIR}","libbufr_4.a"))
setenv("BUFR_LIB8",    pathJoin(base,"${CMAKE_INSTALL_LIBDIR}","libbufr_8.a"))
setenv("BUFR_LIBd",    pathJoin(base,"${CMAKE_INSTALL_LIBDIR}","libbufr_d.a"))
setenv("BUFR_INC4_DA", pathJoin(base,"include_4_DA"))
setenv("BUFR_INC8_DA", pathJoin(base,"include_8_DA"))
setenv("BUFR_INCd_DA", pathJoin(base,"include_d_DA"))
setenv("BUFR_LIB4_DA", pathJoin(base,"${CMAKE_INSTALL_LIBDIR}","libbufr_4_DA.a"))
setenv("BUFR_LIB8_DA", pathJoin(base,"${CMAKE_INSTALL_LIBDIR}","libbufr_8_DA.a"))
setenv("BUFR_LIBd_DA", pathJoin(base,"${CMAKE_INSTALL_LIBDIR}","libbufr_d_DA.a"))

prepend_path("PATH", pathJoin(base,"bin"))
local pydir = pathJoin(base,"${CMAKE_INSTALL_LIBDIR}","python${PYTHON_VERSION}/site-packages")
if (isDir(pydir)) then
  prepend_path("PYTHONPATH", pydir)
end

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: " .. pkgName .. " library")
