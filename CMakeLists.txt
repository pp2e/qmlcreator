cmake_minimum_required(VERSION 3.16)

project(qmlcreator LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup()

qt_policy(SET QTP0001 NEW)

add_subdirectory(src)
