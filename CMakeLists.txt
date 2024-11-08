cmake_minimum_required(VERSION 3.20)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/Modules")

include(Options)

include(CMakePolicy NO_POLICY_SCOPE)

project(cmake_project_template
        VERSION 0.1.0
        DESCRIPTION "A template for CMake projects"
        LANGUAGES C CXX)

include(CompilerOptions)
include(VCPKGOptions)

include(Messages)

add_subdirectory(src)

message_project_variables()
