cmake_minimum_required(VERSION 3.24)

project(qmlcreator LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)
find_package(Qt6LinguistTools REQUIRED CMAKE_FIND_ROOT_PATH_BOTH)
find_package(Qt6ShaderToolsTools REQUIRED CMAKE_FIND_ROOT_PATH_BOTH)
qt_standard_project_setup()
qt_policy(SET QTP0001 NEW)

set(BUILD_TESTING OFF)
find_package(ECM REQUIRED)

add_subdirectory(src)

find_package(KF6Kirigami)
if (KF6Kirigami_FOUND)
    message("Using system kirigami")
else()
    message("Building kirigami")
    set(BUILD_SHARED_LIBS OFF)
    add_subdirectory(3rdparty/kirigami)
    target_link_libraries(qmlcreator PRIVATE Kirigamiplugin)
endif()
