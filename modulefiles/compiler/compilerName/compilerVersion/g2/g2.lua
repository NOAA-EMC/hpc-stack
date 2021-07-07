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

setenv("g2_ROOT", base)
setenv("g2_VERSION", pkgVersion)
setenv("G2_INC4", pathJoin(base,"include_4"))
setenv("G2_INCd", pathJoin(base,"include_d"))
setenv("G2_LIB4", pathJoin(base,"${CMAKE_INSTALL_LIBDIR}","libg2_4.a"))
setenv("G2_LIBd", pathJoin(base,"${CMAKE_INSTALL_LIBDIR}","libg2_d.a"))

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: " .. pkgName .. " library")
