find_package(Qt6 REQUIRED COMPONENTS
             Core
             Gui
             Widgets
             )

file(GLOB SOURCES
     "src/*.hpp"
     "src/*.cpp"
     )

file(GLOB UI_FILES
     "src/ui/*.ui"
     )

add_executable(${PROJECT_NAME}-gui WIN32
               ${SOURCES}
               res/resources.qrc
               ${UI_FILES}
               )

set_target_properties(${PROJECT_NAME}-gui PROPERTIES
                      AUTOMOC ON
                      AUTOUIC ON
                      AUTORCC ON
                      AUTOUIC_SEARCH_PATHS "src/ui"
                      )

target_include_directories(${PROJECT_NAME}-gui PRIVATE
                           "src"
                           )

target_link_libraries(${PROJECT_NAME}-gui PRIVATE
                      Qt6::Core
                      Qt6::Gui
                      Qt6::Widgets
                      )

if(WIN32)
    get_target_property(_qmake_executable Qt6::qmake IMPORTED_LOCATION)
    get_filename_component(_qt_bin_dir "${_qmake_executable}" DIRECTORY)

    set(DEBUG_SUFFIX)

    if(MSVC AND CMAKE_BUILD_TYPE MATCHES "Debug")
        set(DEBUG_SUFFIX "d")
    endif()

    set(QT_VERSION 6)
    set(QT_INSTALL_PATH "${_qt_bin_dir}")

    if(NOT EXISTS "${QT_INSTALL_PATH}/bin")
        set(QT_INSTALL_PATH "${QT_INSTALL_PATH}/..")
        if(NOT EXISTS "${QT_INSTALL_PATH}/bin")
            set(QT_INSTALL_PATH "${QT_INSTALL_PATH}/..")
        endif()
    endif()

    if(Qt6_FOUND AND TARGET Qt6::qmake AND NOT TARGET Qt6::windeployqt)
        get_target_property(_qt6_qmake_location Qt6::qmake IMPORTED_LOCATION)

        execute_process(
            COMMAND "${_qt5_qmake_location}" -query QT_INSTALL_PREFIX
            RESULT_VARIABLE return_code
            OUTPUT_VARIABLE qt6_install_prefix
            OUTPUT_STRIP_TRAILING_WHITESPACE
            )

        set(imported_location "${QT_INSTALL_PATH}/bin/windeployqt6.exe")

        if(EXISTS ${imported_location})
            add_executable(Qt6::windeployqt IMPORTED)

            set_target_properties(Qt6::windeployqt PROPERTIES
                                  IMPORTED_LOCATION ${imported_location}
                                  )
        endif()
    endif()

    if(TARGET Qt6::windeployqt)
        add_custom_command(TARGET ${PROJECT_NAME}-gui POST_BUILD
                           COMMAND Qt6::windeployqt
                           --no-translations
                           --no-opengl-sw
                           --no-system-d3d-compiler
                           --skip-plugin-types "iconengines,imageformats,\
                           styles,tls,\
                           networkinformation,generic,accessibility,\
                           geometryloader,printsupport,platforminputcontexts,\
                           qmltooling,webp,webp-imageformat,\
                           svg,svg-image-format,svgicon,svg-icon-plugin,\
                           qjpeg,qgif,qicns,qico,qjp2,qmng,qsvg,qsvgicon,\
                           qwbmp,qwebp,qtharfbuzzng,qtpdf,qtpng,qtraw,qtsvg,\
                           qtga,qtiff,qtmac,qtpcx,qtexr,qtiff,qtrgba,qtwebp"
                           --include-plugins qwindows
                           $<TARGET_FILE:${PROJECT_NAME}-gui>
                           COMMENT "Deploying Qt..."
                           )

        if(DEFINED ENV{MINGW_INSTALL} AND CMAKE_CXX_COMPILER_ID STREQUAL
           "GNU" OR (
           CMAKE_CXX_COMPILER_ID STREQUAL "Clang" AND NOT USE_LIBCXX)
           )
            foreach(LIB_DLL "libgcc_s_seh-1.dll" "libstdc++-6.dll")
                add_custom_command(TARGET ${PROJECT_NAME}-gui POST_BUILD
                                   COMMAND ${CMAKE_COMMAND} -E remove -f
                                   "$<TARGET_FILE_DIR:${PROJECT_NAME}-gui>/${LIB_DLL}"
                                   $<TARGET_FILE_DIR:${PROJECT_NAME}-gui>
                                   )
                add_custom_command(TARGET ${PROJECT_NAME}-gui POST_BUILD
                                   COMMAND ${CMAKE_COMMAND} -E copy
                                   "$ENV{MINGW_INSTALL}/bin/${LIB_DLL}"
                                   $<TARGET_FILE_DIR:${PROJECT_NAME}-gui>
                                   )
            endforeach()
        elseif(DEFINED ENV{CLANG_INSTALL} AND
               CMAKE_CXX_COMPILER_ID STREQUAL "Clang" AND ${USE_LIBCXX})
            foreach(LIB_DLL "libc++.dll" "libunwind.dll" "libgcc_s_seh-1.dll")
                add_custom_command(TARGET ${PROJECT_NAME}-gui POST_BUILD
                                   COMMAND ${CMAKE_COMMAND} -E remove -f
                                   "$<TARGET_FILE_DIR:${PROJECT_NAME}-gui>/${LIB_DLL}"
                                   $<TARGET_FILE_DIR:${PROJECT_NAME}-gui>
                                   )
            endforeach()

            add_custom_command(TARGET ${PROJECT_NAME}-gui POST_BUILD
                               COMMAND ${CMAKE_COMMAND} -E copy
                               "$ENV{CLANG_INSTALL}/bin/libc++.dll"
                               $<TARGET_FILE_DIR:${PROJECT_NAME}-gui>
                               )
            add_custom_command(TARGET ${PROJECT_NAME}-gui POST_BUILD
                               COMMAND ${CMAKE_COMMAND} -E copy
                               "${QT_INSTALL_PATH}/bin/libunwind.dll"
                               $<TARGET_FILE_DIR:${PROJECT_NAME}-gui>
                               )
        endif()
    endif()
endif()