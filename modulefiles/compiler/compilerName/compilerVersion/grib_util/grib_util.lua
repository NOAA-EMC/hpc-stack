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

setenv("grib_util_ROOT", base)
prepend_path("PATH", pathJoin(base, "bin"))

setenv("CNVGRIB",   pathJoin(base, "bin", "cnvgrib"))
setenv("COPYGB",    pathJoin(base, "bin", "copygb"))
setenv("COPYGB2",   pathJoin(base, "bin", "copygb2"))
setenv("DEGRIB2",   pathJoin(base, "bin", "degrib2"))
setenv("GRB2INDEX", pathJoin(base, "bin", "grb2index"))
setenv("GRBINDEX",  pathJoin(base, "bin", "grbindex"))
setenv("GRIB2GRIB", pathJoin(base, "bin", "grib2grib"))
setenv("TOCGRIB",   pathJoin(base, "bin", "tocgrib"))
setenv("TOCGRIB2",  pathJoin(base, "bin", "tocgrib2"))
setenv("TOCGRIB2SUPER",  pathJoin(base, "bin", "tocgrib2super"))
setenv("WGRIB",     pathJoin(base, "bin", "wgrib"))

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: Utility")
whatis("Description: " .. pkgName .. " utility")
