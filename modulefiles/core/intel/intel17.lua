help([[
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

family("compiler")

conflict(pkgName)
conflict("gnu")

local opt = os.getenv("HPC_OPT") or os.getenv("OPT") or "/opt/modules"
local mklroot = "/opt/intel17/compilers_and_libraries_2017.1.132/linux/mkl"

prepend_path("PATH","/opt/intel17/compilers_and_libraries_2017.1.132/linux/bin/intel64:/opt/intel17/compilers_and_libraries_2017.1.132/linux/mpi/intel64/bin:/opt/intel17/debugger_2017/gdb/intel64_mic/bin")

prepend_path("LD_LIBRARY_PATH","/opt/intel17/compilers_and_libraries_2017.1.132/linux/compiler/lib/intel64:/opt/intel17/compilers_and_libraries_2017.1.132/linux/compiler/lib/intel64_lin:/opt/intel17/compilers_and_libraries_2017.1.132/linux/mpi/intel64/lib:/opt/intel17/compilers_and_libraries_2017.1.132/linux/mpi/mic/lib:/opt/intel17/compilers_and_libraries_2017.1.132/linux/ipp/lib/intel64:/opt/intel17/compilers_and_libraries_2017.1.132/linux/compiler/lib/intel64_lin:/opt/intel17/compilers_and_libraries_2017.1.132/linux/mkl/lib/intel64_lin:/opt/intel17/compilers_and_libraries_2017.1.132/linux/tbb/lib/intel64/gcc4.7:/opt/intel17/debugger_2017/iga/lib:/opt/intel17/debugger_2017/libipt/intel64/lib:/opt/intel17/compilers_and_libraries_2017.1.132/linux/daal/lib/intel64_lin:/opt/intel17/compilers_and_libraries_2017.1.132/linux/daal/../tbb/lib/intel64_lin/gcc4.4")

prepend_path("LIBRARY_PATH","/opt/intel17/compilers_and_libraries_2017.1.132/linux/ipp/lib/intel64:/opt/intel17/compilers_and_libraries_2017.1.132/linux/compiler/lib/intel64_lin:/opt/intel17/compilers_and_libraries_2017.1.132/linux/mkl/lib/intel64_lin:/opt/intel17/compilers_and_libraries_2017.1.132/linux/tbb/lib/intel64/gcc4.7:/opt/intel17/compilers_and_libraries_2017.1.132/linux/daal/lib/intel64_lin:/opt/intel17/compilers_and_libraries_2017.1.132/linux/daal/../tbb/lib/intel64_lin/gcc4.4")

prepend_path("MANPATH","/opt/intel17/man/common:/opt/intel17/compilers_and_libraries_2017.1.132/linux/mpi/man:/opt/intel17/documentation_2017/en/debugger//gdb-ia/man/:/opt/intel17/documentation_2017/en/debugger//gdb-mic/man/:/opt/intel17/documentation_2017/en/debugger//gdb-igfx/man/:/usr/local/man:/usr/local/share/man:/usr/share/man")

setenv("CLASSPATH","/opt/intel17/compilers_and_libraries_2017.1.132/linux/mpi/intel64/lib/mpi.jar:/opt/intel17/compilers_and_libraries_2017.1.132/linux/daal/lib/daal.jar")

setenv("CPATH","/opt/intel17/compilers_and_libraries_2017.1.132/linux/ipp/include:/opt/intel17/compilers_and_libraries_2017.1.132/linux/mkl/include:/opt/intel17/compilers_and_libraries_2017.1.132/linux/tbb/include:/opt/intel17/compilers_and_libraries_2017.1.132/linux/daal/include")

setenv("NLSPATH","/opt/intel17/compilers_and_libraries_2017.1.132/linux/compiler/lib/intel64/locale/%l_%t/%N:/opt/intel17/compilers_and_libraries_2017.1.132/linux/mkl/lib/intel64_lin/locale/%l_%t/%N:/opt/intel17/debugger_2017/gdb/intel64_mic/share/locale/%l_%t/%N:/opt/intel17/debugger_2017/gdb/intel64/share/locale/%l_%t/%N")

setenv("MIC_LD_LIBRARY_PATH","/opt/intel17/compilers_and_libraries_2017.1.132/linux/mpi/mic/lib:/opt/intel17/compilers_and_libraries_2017.1.132/linux/compiler/lib/mic:/opt/intel17/compilers_and_libraries_2017.1.132/linux/ipp/lib/mic:/opt/intel17/compilers_and_libraries_2017.1.132/linux/compiler/lib/intel64_lin_mic:/opt/intel17/compilers_and_libraries_2017.1.132/linux/mkl/lib/intel64_lin_mic:/opt/intel17/compilers_and_libraries_2017.1.132/linux/tbb/lib/mic")

setenv("MIC_LIBRARY_PATH","/opt/intel17/compilers_and_libraries_2017.1.132/linux/mpi/mic/lib:/opt/intel17/compilers_and_libraries_2017.1.132/linux/compiler/lib/mic:/opt/intel17/compilers_and_libraries_2017.1.132/linux/compiler/lib/intel64_lin_mic:/opt/intel17/compilers_and_libraries_2017.1.132/linux/mkl/lib/intel64_lin_mic:/opt/intel17/compilers_and_libraries_2017.1.132/linux/tbb/lib/mic")

setenv("MPM_LAUNCHER","/opt/intel17/debugger_2017/mpm/mic/bin/start_mpm.sh")
setenv("NDK_ARCH","x86_64")
setenv("COMPILERVARS_ARGV","1")
setenv("GDBSERVER_MIC","/opt/intel17/debugger_2017/gdb/targets/mic/bin/gdbserver")
setenv("GDB_CROSS","/opt/intel17/debugger_2017/gdb/intel64_mic/bin/gdb-mic")
setenv("CPRO_PATH","/opt/intel17/compilers_and_libraries_2017.1.132/linux")
setenv("DAALROOT","/opt/intel17/compilers_and_libraries_2017.1.132/linux/daal")
setenv("INFOPATH","/opt/intel17/documentation_2017/en/debugger//gdb-ia/info/:/opt/intel17/documentation_2017/en/debugger//gdb-mic/info/:/opt/intel17/documentation_2017/en/debugger//gdb-igfx/info/")
setenv("INTEL_LICENSE_FILE","/opt/intel17/compilers_and_libraries_2017.1.132/linux/licenses:/opt/intel17/licenses:/home/ubuntu/intel17/licenses")
setenv("INTEL_PYTHONHOME","/opt/intel17/debugger_2017/python/intel64/")
setenv("INTEL_TARGET_ARCH","intel64")
setenv("INTEL_TARGET_PLATFORM","linux")
setenv("IPPROOT","/opt/intel17/compilers_and_libraries_2017.1.132/linux/ipp")
setenv("PROD_DIR","/opt/intel17/compilers_and_libraries_2017.1.132/linux")
setenv("TBBROOT","/opt/intel17/compilers_and_libraries_2017.1.132/linux/tbb")
setenv("TBB_TARGET_ARCH","intel64")
setenv("TBB_TARGET_PLATFORM","linux")

setenv("FC",  "ifort")
setenv("CC",  "icc")
setenv("CXX", "icpc")
setenv("SERIAL_FC",  "ifort")
setenv("SERIAL_CC",  "icc")
setenv("SERIAL_CXX", "icpc")

setenv("MKLROOT", mklroot)
setenv("MKLINCLUDE", pathJoin(mklroot,"include"))
prepend_path("LD_LIBRARY_PATH",pathJoin(mklroot,"lib/intel64"))
prepend_path("LIBRARY_PATH",pathJoin(mklroot,"lib/intel64"))
prepend_path("CPATH",pathJoin(mklroot,"include"))
prepend_path("CPRO_PATH",pathJoin(mklroot,"include"))

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: Compiler")
whatis("Description: GNU Compiler Family and module access")
