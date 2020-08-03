help([[
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

family("stack")

conflict(pkgName)

local opt = "#HPC_OPT#"
setenv("HPC_OPT", opt)

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: Base")
whatis("Description: Initialize HPC software stack")
