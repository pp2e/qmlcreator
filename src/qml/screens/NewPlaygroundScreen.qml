import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QmlCreator
import "../components"

import org.kde.kirigami as Kirigami

Kirigami.Page {
    id: playgroundScreen
    padding: 0

    property string filePath: ""

    function getDirName(path) {
        var lastSlash = path.lastIndexOf("/");
        if (lastSlash === -1) return path;
        return path.slice(lastSlash+1);
    }

    title: getDirName(filePath)
    actions: [
        Kirigami.Action {
            icon.name: "showinfo"
            checkable: true
            checked: settings.debugging
            text: qsTr("Debug")
            tooltip: settings.debugging ? qsTr("Disable debugging") : qsTr("Enable debugging")
            onTriggered: settings.debugging = !settings.debugging
        }
    ]

    Component.onCompleted: {
        windowLoader.source = ProjectManager.getFilePath(filePath)
        windowContainer.window = windowLoader.window
    }
    Component.onDestruction: {
        windowLoader.source = ""
    }
    Kirigami.ColumnView.onInViewportChanged: {
        if (Kirigami.ColumnView.inViewport) {
            windowContainer.window = windowLoader.window
            logWindow.visible = settings.debugging
        } else {
            windowContainer.window = null
            logWindow.hide()
        }
    }

    WindowContainer {
        id: windowContainer
        anchors.fill: parent
    }

    Window {
        id: logWindow
        visible: settings.debugging
        color: "transparent"
        parent: playgroundScreen
        width: playgroundScreen.width
        height: playgroundScreen.height

        flags: Qt.WindowTransparentForInput

        TextEdit {
            id: messages
            width: parent.width
            height: parent.height
            color: appWindow.colorPalette.editorNormal
            opacity: 0.3
            font.pixelSize: 6 * settings.pixelDensity
            wrapMode: TextEdit.Wrap
            readOnly: true
        }

        Connections {
            target: messageHandler
            function onMessageReceived(message) {
                messages.append(message)
            }
        }

        Connections {
            target: windowLoader
            function onError(error) {
                messages.append(error)
            }
        }
    }
}
