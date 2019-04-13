include(InstallRequiredSystemLibraries)
#######
# CPack
##

configure_file(
    "${CMAKE_SOURCE_DIR}/SDL2_imageCPackOptions.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/SDL2_imageCPackOptions.cmake" @ONLY
)
set(CPACK_PROJECT_CONFIG_FILE "${CMAKE_CURRENT_BINARY_DIR}/SDL2_imageCPackOptions.cmake")

# This must always be last!
include(CPack)
