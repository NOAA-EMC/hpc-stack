find_path (WGRIB2_INCLUDES
  wgrib2api.mod
  HINTS $ENV{wgrib2_ROOT}/include)

find_library (LIBWGRIB2
  names libwgrib2.a
  HINTS $ENV{wgrib2_ROOT}/lib)

find_library (LIBWGRIB2_API
  names libwgrib2_api.a
  HINTS $ENV{wgrib2_ROOT}/lib)

set(WGRIB2_LIBRARIES ${LIBWGRIB2} ${LIBWGRIB2_API})

if(EXISTS ${WGRIB2_INCLUDES} AND EXISTS ${LIBWGRIB2})
  message(STATUS "Found WGRIB2: include directory ${WGRIB2_INCLUDES}, library ${WGRIB2_LIBRARIES}")
else()
  message(STATUS "Unable to locate WGRIB2 library and/or Fortran modules")
endif()

mark_as_advanced (WGRIB2_INCLUDES WGRIB2_LIBRARIES)

add_library(wgrib2::wgrib2 UNKNOWN IMPORTED)
set_target_properties(wgrib2::wgrib2 PROPERTIES
  IMPORTED_LOCATION "${WGRIB2_LIBRARIES}"
  INTERFACE_INCLUDE_DIRECTORIES "${WGRIB2_INCLUDES}"
  INTERFACE_LINK_LIBRARIES "${WGRIB2_LIBRARIES}")
