macro(find_qt PATH)
    if(WIN32)
        if(EXISTS "${PATH}/bin")
            set(CMAKE_PREFIX_PATH
                ${CMAKE_PREFIX_PATH}
                "${PATH}"
                )
        else()
            if(NOT EXISTS "${PATH}/llvm-mingw_64"
               AND NOT EXISTS "${PATH}/mingw_64"
               AND NOT EXISTS "${PATH}/msvc*")
                message(FATAL_ERROR "QT_INSTALL is not set to a valid path")
            endif()

            if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang" AND ${USE_LIBCXX})
                set(CMAKE_PREFIX_PATH
                    ${CMAKE_PREFIX_PATH}
                    "${PATH}/llvm-mingw_64"
                    )
            elseif(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC" OR ${CLANG_MSVC})
                file(GLOB qt_install_dirs "${PATH}" FOLLOW_SYMLINKS "${PATH}/msvc*")

                if(qt_install_dirs)
                    set(CMAKE_PREFIX_PATH
                        ${CMAKE_PREFIX_PATH}
                        ${qt_install_dirs}
                        )
                else()
                    message(FATAL_ERROR "QT_INSTALL is not set to a valid path")
                endif()

                unset(qt_install_dirs)
            else()
                set(CMAKE_PREFIX_PATH
                    ${CMAKE_PREFIX_PATH}
                    "${PATH}/mingw_64"
                    )
            endif()
        endif()
    elseif(UNIX)
        set(CMAKE_PREFIX_PATH
            ${CMAKE_PREFIX_PATH}
            "${PATH}"
            )
    endif()
endmacro()

macro(find_system_qt qt_found)
    if(WIN32)
        if(EXISTS "C:/Qt")
            file(GLOB _qt_install_dirs RELATIVE "C:/Qt" FOLLOW_SYMLINKS "C:/Qt/*")

            if(_qt_install_dirs)
                foreach(_qt_install_dir ${_qt_install_dirs})
                    if(_qt_install_dir MATCHES "(6\\.[0-9]+\\.[0-9]+)")
                        find_qt("C:/Qt/${_qt_install_dir}")
                        set(${qt_found} ON)
                        break()
                    endif()
                endforeach()
            endif()
            unset(_qt_install_dirs)
        endif()
    endif()
endmacro()

macro(find_qt_for_project)
    message(STATUS "Looking for Qt6")
    if(DEFINED ENV{QT_INSTALL})
        find_qt($ENV{QT_INSTALL})
    else()
        find_package(Qt6 COMPONENTS Core)

        if(NOT Qt6_FOUND)
            set(qt_found OFF)

            find_system_qt(qt_found)

            if(NOT qt_found)
                message(FATAL_ERROR "Qt6 not found!")
            endif()

            unset(qt_found)
        endif()
    endif()

    message(STATUS "Qt6 found")
endmacro()

find_qt_for_project()