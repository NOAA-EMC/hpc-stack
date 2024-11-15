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

local libdir = "lib"
if (isFile(pathJoin(base,"lib64","libbufr_4.a"))) then
  libdir = "lib64"
end

setenv("bufr_ROOT", base)
setenv("bufr_VERSION", pkgVersion)
setenv("BUFR_INC4",    pathJoin(base,libdir,"include_4"))
setenv("BUFR_LIB4",    pathJoin(base,libdir,"libbufr_4.a"))
prepend_path("PATH", pathJoin(base,"bin"))
local pydir = pathJoin(base,libdir,"python${PYTHON_VERSION}/site-packages")
if (isDir(pydir)) then
  prepend_path("PYTHONPATH", pydir)
end

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: library")
whatis("Description: " .. pkgName .. " library")
