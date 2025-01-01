qt_add_qml_module(quicktoolingfixed
    URI QtQuick.tooling
    RESOURCE_PREFIX /qt-project.org/imports/
    OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/QtQuick/tooling
    VERSION 1.2

    QML_FILES
    Component.qml
    Enum.qml
    Member.qml
    Method.qml
    Module.qml
    Parameter.qml
    Property.qml
    Signal.qml
)
