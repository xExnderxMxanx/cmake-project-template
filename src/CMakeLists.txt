include_directories(.)
include_directories(${CMAKE_CURRENT_BINARY_DIR}/lib)

add_subdirectory(lib)

add_subdirectory(core)

if (BUILD_TESTS)
    add_subdirectory(test)
endif ()