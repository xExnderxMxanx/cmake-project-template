set(CMAKE_CXX_STANDARD 20 CACHE STRING "C++ standard to conform to")
set(CMAKE_CXX_STANDARD_REQUIRED ON CACHE BOOL "C++ standard is required")

if(NOT DEFINED Python3_EXECUTABLE)
    find_package(Python3 REQUIRED)

    message(STATUS "Python3 executable: ${Python3_EXECUTABLE}")

    set(Python_EXECUTABLE ${Python3_EXECUTABLE})
endif()

if(CYGWIN)
    set(CMAKE_CXX_EXTENSIONS ON CACHE BOOL "C++ extensions")
else()
    set(CMAKE_CXX_EXTENSIONS OFF CACHE BOOL "C++ extensions")
endif()

if(DEFINED ENV{CLANG_INSTALL})
    set(CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH} $ENV{CLANG_INSTALL})
endif()

if(DEFINED ENV{MINGW_INSTALL})
    set(CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH} $ENV{MINGW_INSTALL})
endif()

if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang"
   AND CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC")
    set(CLANG_MSVC ON)
else()
    set(CLANG_MSVC OFF)
endif()

if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU"
   OR (CMAKE_CXX_COMPILER_ID STREQUAL "Clang" AND NOT ${CLANG_MSVC}))
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++20 -fexec-charset=UTF-8")
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC" OR ${CLANG_MSVC})
    set(CMAKE_CXX_FLAGS "/std:c++20 /utf-8")
endif()

if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC" OR CMAKE_CXX_COMPILER_ID STREQUAL
   "GNU" OR ${CLANG_MSVC})
    set(USE_LIBCXX OFF)
endif()

macro(clang_sanitizer)
    if(CMAKE_BUILD_TYPE STREQUAL "Debug")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-omit-frame-pointer")
        if(CLANG_SANITIZE)
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fsanitize=address")
        endif()
    endif()
endmacro()

if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang" AND ${USE_LIBCXX} AND NOT
   ${CLANG_MSVC})
    find_package(Clang ${CMAKE_CXX_COMPILER_VERSION} REQUIRED)
    find_package(LLVM ${CMAKE_CXX_COMPILER_VERSION} REQUIRED)

    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libc++")

    set(CMAKE_EXE_LINKER_FLAGS
        "${CMAKE_EXE_LINKER_FLAGS} -stdlib=libc++ -lc++ -lunwind -fuse-ld=lld"
        )

    if(UNIX)
        set(CMAKE_EXE_LINKER_FLAGS
            "${CMAKE_EXE_LINKER_FLAGS} -lc++abi"
            )
    endif()

    add_compile_definitions("USE_LIBCXX")

    clang_sanitizer()
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR (
       CMAKE_CXX_COMPILER_ID STREQUAL "Clang" AND NOT ${USE_LIBCXX}
       AND NOT ${CLANG_MSVC})
       )
    add_compile_definitions("USE_LIBSTDCXX")

    if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
        clang_sanitizer()
    endif()
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC" OR ${CLANG_MSVC})
    add_compile_definitions("USE_MSVC")
else()
    message(WARNING "Unknown compiler: ${CMAKE_CXX_COMPILER_ID}")
endif()

if(CMAKE_BUILD_TYPE STREQUAL "Debug" OR CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo")
    add_compile_definitions("DEBUG")
else()
    add_compile_definitions("NDEBUG")
endif()

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")

if(WIN32)
    set(CMAKE_SHARED_LIBRARY_PREFIX "")
else()
    set(CMAKE_SHARED_LIBRARY_PREFIX "lib")
endif()