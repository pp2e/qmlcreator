# qt_add_library(quicktoolingfixed STATIC)
# qt_add_library(quicktoolingfixedplugin STATIC)
# qt_add_qml_module(quicktoolingfixed
#     URI QtQuick.tooling
#     RESOURCE_PREFIX /qt-project.org/imports/
#     OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/QtQuick/tooling
#     VERSION 1.2

#     QML_FILES
#     Component.qml
#     Enum.qml
#     Member.qml
#     Method.qml
#     Module.qml
#     Parameter.qml
#     Property.qml
#     Signal.qml
# )
qt_add_resources(qmlcreator quicktoolingfixed
    PREFIX /qt-project.org/imports/QtQuick/tooling

    FILES
    Component.qml
    Enum.qml
    Member.qml
    Method.qml
    Module.qml
    Parameter.qml
    Property.qml
    Signal.qml
    qmldir
)
