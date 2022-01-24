help([[
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

family("python")

conflict(pkgName)
conflict("python")
conflict("intelpython")

local opt = os.getenv("HPC_OPT") or os.getenv("OPT") or "/opt/modules"

local mpath = pathJoin(opt,"modulefiles/python",pkgName,pkgVersion)
prepend_path("MODULEPATH", mpath)

local base = pathJoin(opt,"core",pkgName,pkgVersion)

setenv("CONDA_ROOT",               base)
setenv("CONDA_ENVS_PATH", pathJoin(base,"envs"))
setenv("CONDA_PKGS_DIRS", pathJoin(base,"pkgs"))
setenv("CONDARC",         pathJoin(base,".condarc"))

if (myShellType() == "sh") then
  shell_to_source = "bash"
  file_to_source = pathJoin(base, "etc/profile.d/conda.sh")
else
  if (myShellType() == "csh") then
    shell_to_source = "csh"
    file_to_source = pathJoin(base, "etc/profile.d/conda.csh")
  end
end

source_sh(shell_to_source, file_to_source)

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: Python")
whatis("Description: Miniconda3 Family")
