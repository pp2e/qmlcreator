import QtQuick
import QtQuick.Controls

Window {
    id: window
    visible: true

    property alias text: text.text

    Column {
        Text {
            text: "⚠️Cannot launch QML Creator⚠️"
        }

        Text {
            id: text
            wrapMode: Text.Wrap
            width: window.width
        }

        Button {
            text: "Load builtin main.qml"
            enabled: false
            onClicked: window.loadBuiltin()
        }
    }
}
