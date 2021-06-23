help([[
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

local hierA          = hierarchyA(pkgNameVer,1)
local pythonNameVer  = hierA[1]
local pythonNameVerD = pythonNameVer:gsub("/","-")

conflict(pkgName)

local opt = os.getenv("HPC_OPT") or os.getenv("OPT") or "/opt/modules"

local base = pathJoin(opt,pythonNameVerD,pkgName,pkgVersion)

-- activate on load, deactivate on unload
if (mode() == "load") then
  local source_cmd = "source " .. pathJoin(base, "bin/activate")
  execute{cmd=source_cmd, modeA={"load"}}
else
  if (mode() == "unload") then
    execute{cmd="deactivate", modeA={"unload"}}
  end
end

-- The next 2 lines are automatically added (removed) by activate (deactivate)
-- Hence, there is no need to add here.
--prepend_path("PATH", pathJoin(base,"bin"))
--prepend_path("PYTHONPATH", pathJoin(base,"lib/python@PYTHON_VERSION@/site-packages"))

whatis("Name: " .. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: Software")
whatis("Description: " .. pkgName .. " Python Virtual Environment")
