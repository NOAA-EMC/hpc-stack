cmake_minimum_required(VERSION 3.0)
project(test_install_dir LANGUAGES C)
include(GNUInstallDirs)

file(WRITE "cmake_install_libdir.txt" ${CMAKE_INSTALL_LIBDIR})
