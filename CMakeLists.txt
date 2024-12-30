cmake_minimum_required(VERSION 3.24)

project(qmlcreator LANGUAGES CXX C)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)
find_package(Qt6LinguistTools REQUIRED CMAKE_FIND_ROOT_PATH_BOTH)
find_package(Qt6ShaderToolsTools REQUIRED CMAKE_FIND_ROOT_PATH_BOTH)
qt_standard_project_setup()
qt_policy(SET QTP0001 NEW)

# set(BUILD_TESTING OFF)
# find_package(ECM REQUIRED)

add_subdirectory(src)

# find_package(KF6Kirigami)
# if (KF6Kirigami_FOUND)
#     message("Using system kirigami")
# else()
#     message("Building kirigami")
#     # Fix OpenMP breaks android build
#     set(CMAKE_DISABLE_FIND_PACKAGE_OpenMP ON)
#     set(BUILD_SHARED_LIBS OFF)
#     add_subdirectory(3rdparty/kirigami)
#     target_link_libraries(qmlcreator PRIVATE Kirigamiplugin)
# endif()

add_subdirectory(3rdparty/qtquick.tooling)
target_link_libraries(qmlcreator PRIVATE quicktoolingfixed)

function(bundle_qml_imports_types target)
    # conf=probably ok
    include("${CMAKE_CURRENT_BINARY_DIR}/src/.qt/qml_imports/${target}_conf.cmake")

    math(EXPR last_index "${qml_import_scanner_imports_count} - 1")
    foreach(index RANGE 0 ${last_index})
        cmake_parse_arguments("entry"
            ""
            "PATH;PREFER"
            ""
            ${qml_import_scanner_import_${index}}
        )
        if ("${entry_PREFER}" MATCHES ":.*")
            file(GLOB types "${entry_PATH}/*.qmltypes")
            STRING(REGEX REPLACE "^:/" "" prefix ${entry_PREFER})
            qt_add_resources(${target} ${prefix}bundle_qmltypes.qrc PREFIX "${prefix}" BASE "${entry_PATH}" FILES ${types})
        endif()
    endforeach()

endfunction()

bundle_qml_imports_types(qmlcreator)
