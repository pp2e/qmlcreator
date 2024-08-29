import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QmlCreator
import "../components"

BlankScreen {
    id: playgroundScreen

    property string filePath: ""

    function getDirName(path) {
        var lastSlash = path.lastIndexOf("/");
        if (lastSlash === -1) return path;
        return path.slice(lastSlash+1);
    }

    StackView.onStatusChanged: {
        if (StackView.status === StackView.Activating) {
            windowLoader.source = ProjectManager.getFilePath(filePath)
            windowContainer.window = windowLoader.window
        }
        else if (StackView.status === StackView.Deactivating) {
            logWindow.hide()
            windowLoader.source = ""
        }
    }

    CToolBar {
        id: toolBar

        RowLayout {
            anchors.fill: parent
            spacing: 0

            CBackButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                //enabled: !leftView.busy
                //enableBack: !enableDualView
                text: getDirName(filePath)
                onClicked: windowLoader.source = ""
            }

            CToolButton {
                icon: "\uf188"
                tooltipText: settings.debugging ? qsTr("Disable debugging") : qsTr("Enable debugging")
                checked: settings.debugging
                onClicked: {
                    settings.debugging = !settings.debugging
                }
            }
        }
    }

    WindowContainer {
        id: windowContainer
        anchors.top: toolBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
    }

    Window {
        id: logWindow
        visible: settings.debugging
        color: "transparent"
        parent: playgroundScreen
        width: playgroundScreen.width
        height: playgroundScreen.height - toolBar.height
        y: toolBar.height

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
