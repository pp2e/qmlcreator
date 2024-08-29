import QtCore
import QtQuick
import QtQuick.Controls
import QmlCreator

Window {
    id: window
    visible: true

    property alias text: text.text

    Settings {
        id: settings
        location: ProjectManager.settingsPath
        property string qmlEntryPoint
    }

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
            text: "Reset to builtin main.qml"
            onClicked: settings.qmlEntryPoint = ""
        }
    }
}
