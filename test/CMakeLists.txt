cmake_minimum_required(VERSION 3.11)

set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/../cmake)

project(showimage)
add_executable(${PROJECT_NAME} ../../showimage.c)

find_package(SDL2 REQUIRED)
if (NOT SDL2_FOUND)
    message(STATUS "NOOOOO SDL2")
endif()
include_directories(showimage ${SDL2_INCLUDE_DIRS})
target_link_libraries(showimage ${SDL2_LIBRARIES})
find_package(SDL2_image REQUIRED)
if (NOT SDL2_image_FOUND)
    message(STATUS "NOOOOO")
endif()
include_directories(${PROJECT_NAME} SDL2_image::SDL2_image)
target_link_libraries(${PROJECT_NAME} SDL2_image::SDL2_image)
