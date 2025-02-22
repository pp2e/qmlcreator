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

function(bundle_qml_imports_types target)
    find_program(qmlplugindump_tool NAMES qmlplugindump HINTS ${QT_HOST_PATH}/bin)

    # conf=probably ok
    include("${CMAKE_CURRENT_BINARY_DIR}/src/.qt/qml_imports/${target}_conf.cmake")

    math(EXPR last_index "${qml_import_scanner_imports_count} - 1")
    foreach(index RANGE 0 ${last_index})
        cmake_parse_arguments("entry"
            ""
            "NAME;PATH;PREFER"
            ""
            ${qml_import_scanner_import_${index}}
        )
        if("${entry_PREFER}" MATCHES ":.*")
            file(GLOB types "${entry_PATH}/*.qmltypes")
            list(LENGTH types types_count)
            STRING(REGEX REPLACE "^:/" "" prefix ${entry_PREFER})
            if(${types_count} EQUAL 1)
                get_filename_component(qmltypes_name ${types} NAME)
                execute_process(COMMAND mkdir -p ${CMAKE_BINARY_DIR}/qmltypesscan/${prefix})
                execute_process(COMMAND ${qmlplugindump_tool} -output ${CMAKE_BINARY_DIR}/qmltypesscan/${prefix}${qmltypes_name} ${entry_NAME} "")
                # e.g. for QmlCreator plugin qmltypes will not be found
                # QmlCreator qmltypes added individually in src/CMakeLists.txt
                if (EXISTS ${CMAKE_BINARY_DIR}/qmltypesscan/${prefix}${qmltypes_name})
                    list(APPEND qmltypes_files ${CMAKE_BINARY_DIR}/qmltypesscan/${prefix}${qmltypes_name})
                endif()
            endif()
        endif()
    endforeach()

    qt_add_resources(${target} qmltypesscan BASE ${CMAKE_BINARY_DIR}/qmltypesscan/ FILES ${qmltypes_files})
endfunction()

bundle_qml_imports_types(qmlcreator)
