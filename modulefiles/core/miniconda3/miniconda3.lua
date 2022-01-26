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

-- This section highly simplifies for LMod versions 8.6 and above
-- LMod versions 8.6 and above add `source_sh` functionality
-- Until then, follow the kludge below
--local major, minor, patch = string.match(LmodVersion(), "(%d+)%.(%d+)%.(%d+)")
--if (myShellType() == "sh") then
--  shell_to_source = "bash"
--  file_to_source = pathJoin(base, "etc/profile.d/conda.sh")
--else
--  if (myShellType() == "csh") then
--    shell_to_source = "csh"
--    file_to_source = pathJoin(base, "etc/profile.d/conda.csh")
--  end
--end
--source_sh(shell_to_source, file_to_source)

-- Kludge for LMod versions below 8.6
if (myShellType() == "sh") then
  -- These are conda functions defined in conda.sh
  local funcs = "conda __conda_activate __conda_hashr __conda_reactivate __add_sys_prefix_to_path"

  -- Line #: What does it do?
  -- 1: source conda.sh from the installation path
  -- 2: export conda functions silently(> dev/null)
  local load_cmd = "source " .. pathJoin(base, "etc/profile.d/conda.sh") .. "; \
  export -f " .. funcs .. " > /dev/null"

  -- Line #: What does it do?
  -- 1: deactivate all conda envs
  -- 2: unset the conda funcs
  -- 3: define local variable prefix as path to Miniconda installation
  -- 4: remove from PATH all paths to $prefix
  -- 5: unset CONDA_ env. variables that are set via sourcing conda.sh
  -- 6: unset previously set variable $prefix
  local unload_cmd="for i in $(seq ${CONDA_SHLVL:=0}); do conda deactivate; done; \
  unset -f " .. funcs .. "; \
  prefix=" .. base .. "; \
  export PATH=$(echo $PATH | tr ':' '\\n' | grep . | grep -v $prefix | tr '\\n' ':' | sed 's/:$//'); \
  unset $(env | grep -o \"[^=]*CONDA[^=]*\" | grep -v 'CONDA_ENVS_PATH\\|CONDA_PKGS_DIRS\\|CONDARC'); \
  unset prefix"

  -- source conda on load, deactivate on unload
  if (mode() == "load") then
    execute{cmd=load_cmd, modeA={"load"}}
  else
    if (mode() == "unload") then
      execute{cmd=unload_cmd, modeA={"unload"}}
    end
  end

else
  -- For the dinosaur users of csh based shells
  if (myShellType() == "csh") then
    if (mode() == "load") then
      -- source (silently) conda.csh on load
      local load_cmd = "source " .. pathJoin(base, "etc/profile.d/conda.csh") .. " > /dev/null"
      execute{cmd=load_cmd, modeA={"load"}}
    else
      if (mode() == "unload") then
        -- deactivate all conda activates
        local conda_shlvl = os.getenv("CONDA_SHLVL") or 0
        for i = conda_shlvl, 0, -1
        do
          execute{cmd="conda deactivate", modeA={"unload"}}
        end
        -- remove from PATH all paths to prefix
        remove_path("PATH", pathJoin(base, 'condabin'), ":")
        remove_path("path", pathJoin(base, 'condabin'), " ")
        cmd = "env | grep -o '[^=]*CONDA[^=]*' | grep -v 'CONDA_ENVS_PATH|CONDA_PKGS_DIRS|CONDARC'"
        local conda_vars = subprocess(cmd)
        --io.stderr:write('CONDA vars')
        --io.stderr:write(conda_vars)
        -- These are the values of conda_vars, and I for the life of me
        -- cannot figure out how to loop and unset them like in bash
        -- unset the environment variables set by sourcing conda.csh
        execute{cmd="unsetenv CONDA_SHLVL", modeA={"unload"}}
        execute{cmd="unsetenv _CONDA_EXE", modeA={"unload"}}
        execute{cmd="unsetenv CONDA_EXE", modeA={"unload"}}
        execute{cmd="unsetenv _CONDA_ROOT", modeA={"unload"}}
        execute{cmd="unsetenv CONDA_PYTHON_EXE", modeA={"unload"}}
      end
    end
  end
end

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: Python")
whatis("Description: Miniconda3 Family")

