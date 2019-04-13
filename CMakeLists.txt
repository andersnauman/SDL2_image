cmake_minimum_required (VERSION 3.10)
include(GNUInstallDirs)

project(SDL2_image
    VERSION 2.0.3
    LANGUAGES C
    DESCRIPTION
        "SDL2_image is a SDL2-project to add image funcationality"
)
if (APPLE)
    set(APPLE_SOURCE
        IMG_ImageIO.m
        #IMG_UIImage.m
    )
    set(CONFIG_FILES
        "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
        "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
    )
else()
    set(NON_APPLE_SOURCE
        IMG_gif.c
        IMG_tga.c
        IMG_tif.c
        IMG_WIC.c
    )
endif()

set(PUBLIC_HEADERS
    miniz.h
    nanosvg.h
    nanosvgrast.h
    SDL_image.h
)
add_library(${PROJECT_NAME} STATIC
    IMG.c
    IMG_bmp.c
    IMG_jpg.c
    IMG_png.c
    IMG_lbm.c
    IMG_pcx.c
    IMG_pnm.c
    IMG_svg.c
    IMG_webp.c
    IMG_xcf.c
    IMG_xpm.c
    IMG_xv.c
    "${APPLE_SOURCE}"
    "${NON_APPLE_SOURCE}"
    "${PUBLIC_HEADERS}"
    "${CONFIG_FILES}"
)
add_library(${PROJECT_NAME}::${PROJECT_NAME} ALIAS ${PROJECT_NAME})
if (APPLE)
    set_target_properties(${PROJECT_NAME} PROPERTIES
        FRAMEWORK TRUE
        RESOURCE "${CONFIG_FILES}"
    )
endif()

#########
# Headers
###
set_target_properties(${PROJECT_NAME} PROPERTIES PUBLIC_HEADER "${PUBLIC_HEADERS}")
target_include_directories(${PROJECT_NAME} INTERFACE
    $<BUILD_INTERFACE:"${CMAKE_CURRENT_SOURCE_DIR}">
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/SDL2>
)

#################
# What to include
###
##
## Apple will include support for these through Cocoa.
## Window/Linux will activate these through MACRO if-statements.
##
if (NOT APPLE)
    target_compile_definitions(${PROJECT_NAME} PRIVATE LOAD_BMP)
    target_compile_definitions(${PROJECT_NAME} PRIVATE LOAD_GIF)
    target_compile_definitions(${PROJECT_NAME} PRIVATE LOAD_LBM)
    target_compile_definitions(${PROJECT_NAME} PRIVATE LOAD_PCX)
    target_compile_definitions(${PROJECT_NAME} PRIVATE LOAD_PNM)
    target_compile_definitions(${PROJECT_NAME} PRIVATE LOAD_SVG)
    target_compile_definitions(${PROJECT_NAME} PRIVATE LOAD_TGA)
    target_compile_definitions(${PROJECT_NAME} PRIVATE LOAD_WIC)
    target_compile_definitions(${PROJECT_NAME} PRIVATE LOAD_XCF)
    target_compile_definitions(${PROJECT_NAME} PRIVATE LOAD_XPM)
    target_compile_definitions(${PROJECT_NAME} PRIVATE LOAD_XV)
endif()

##############
# Dependencies
###
## Only for android?
##
## Library: PNG
##
target_compile_definitions(${PROJECT_NAME} PRIVATE LOAD_PNG)
if (NOT APPLE)
    find_package(PNG)
    if (PNG_FOUND)
        message(STATUS "PNG - Using pre-installed library")
        target_compile_definitions(${PROJECT_NAME} PRIVATE "${PNG_DEFINITIONS}")
        list(APPEND LIB_INSTALL "${PNG_LIBRARIES}")
        list(APPEND INCLUDE_INSTALL_DIRS "${PNG_INCLUDE_DIRS}")
    else()
        message(STATUS "PNG - No library were found, compiling a static version")
        set(PNG_STATIC ON CACHE BOOL "Build static lib" FORCE)
        set(PNG_SHARED OFF CACHE BOOL "Build shared lib" FORCE)
        add_subdirectory("external/libpng-1.6.32")
        add_dependencies(${PROJECT_NAME} png_static)
        list(APPEND LIB_INSTALL png_static)
    endif()
endif()

##
## Library: TIFF
##
#if (NOT APPLE)
#    add_subdirectory("external/tiff-4.0.8")
#    add_dependencies(${PROJECT_NAME} tiff)
#    target_compile_definitions(${PROJECT_NAME} PRIVATE LOAD_TIF)
#    target_link_libraries(${PROJECT_NAME} tiff)
#    message(STATUS ${TIFF_INCLUDES})
#    include_directories(${PROJECT_NAME} external/tiff-4.0.8/libtiff)
#endif()

##
## Library: SDL2
##
if (APPLE)
    set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
endif()
find_package(SDL2 REQUIRED)
if (SDL2_FOUND)
    list(APPEND INCLUDE_INSTALL_DIRS "${SDL2_INCLUDE_DIRS}")
    if (APPLE)
        list(APPEND LIB_INSTALL "${SDL2_LIBRARIES}" SDL2::Cocoa)
    elseif (UNIX)
        target_link_libraries(${PROJECT_NAME} PRIVATE "${SDL2_LIBRARIES}")
    elseif (WINDOWS)

    endif()
endif()

target_link_libraries(${PROJECT_NAME} PRIVATE ${LIB_INSTALL})
target_include_directories(${PROJECT_NAME} PRIVATE ${INCLUDE_INSTALL_DIRS})

###############
# Config* files
##
include(CMakePackageConfigHelpers)

## Version-file helper
write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
    VERSION
        ${PROJECT_VERSION}
    COMPATIBILITY
        AnyNewerVersion
)
## Config-file helper
configure_package_config_file(
    "${CMAKE_CURRENT_LIST_DIR}/${PROJECT_NAME}Config.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
    PATH_VARS
        LIB_INSTALL
        INCLUDE_INSTALL_DIRS
    INSTALL_DESTINATION
        "${CMAKE_INSTALL_LIBDIR}/${PROJECT_NAME}/cmake"
)

############
# Installing
###
#set(CMAKE_INSTALL_PREFIX install) # Test-case

install(
    TARGETS
        ${PROJECT_NAME}
    EXPORT
        ${PROJECT_NAME}Targets
    PUBLIC_HEADER DESTINATION
        ${CMAKE_INSTALL_INCLUDEDIR}/SDL2
    LIBRARY DESTINATION
        ${CMAKE_INSTALL_LIBDIR}/${PROJECT_NAME}
    ARCHIVE DESTINATION
        ${CMAKE_INSTALL_LIBDIR}/${PROJECT_NAME}
    RUNTIME DESTINATION
        ${CMAKE_INSTALL_BINDIR}
    FRAMEWORK DESTINATION
        .
)

if (APPLE)
    #set(TARGET_DESTINATION $<TARGET_BUNDLE_CONTENT_DIR:${PROJECT_NAME}>) # install(EXPORT ...) cannot yet handle generator-expression in DESTINATION.
    set(TARGET_DESTINATION "${PROJECT_NAME}.framework/Resources")
else()
    set(TARGET_DESTINATION "${CMAKE_INSTALL_LIBDIR}/${PROJECT_NAME}/cmake")
endif()

## Targets-files
install(
    EXPORT
        ${PROJECT_NAME}Targets
    NAMESPACE
        ${PROJECT_NAME}::
    DESTINATION
        "${TARGET_DESTINATION}"
)

if (NOT APPLE)
    ## Config- / ConfigVersion-files
    ## MacOS framework use the "RESOURCE" property
    install(
        FILES
            "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
            "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
        DESTINATION
            "${TARGET_DESTINATION}"
    )
endif()

include(SDL2_imageCPack.cmake)