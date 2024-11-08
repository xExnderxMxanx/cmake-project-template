function(vcpkg_get_install_dir _vcpkg_install_dir)
    file(GLOB _vcpkg_targets_dir RELATIVE $ENV{VCPKG_ROOT}/installed
         FOLLOW_SYMLINKS "$ENV{VCPKG_ROOT}/installed/*")

    set(_find_path "")
    foreach(_dir ${_vcpkg_targets_dir})
        if(IS_DIRECTORY $ENV{VCPKG_ROOT}/installed/${_dir} AND
           NOT ${_dir} STREQUAL "vcpkg")
            list(APPEND _find_path "$ENV{VCPKG_ROOT}/installed/${_dir}")
        endif()
    endforeach()

    if(NOT _find_path)
        message(FATAL_ERROR "VCPKG_ROOT is set, but no suitable target found")
    endif()

    set(${_vcpkg_install_dir} "${_find_path}" PARENT_SCOPE)
endfunction()

if(DEFINED ENV{VCPKG_ROOT})
    vcpkg_get_install_dir(VCPKG_INSTALL_DIR)

    set(CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH} ${VCPKG_INSTALL_DIR})
endif()