import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ProjectManager
import "../components"

BlankScreen {
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
                enabled: !leftView.busy
                enableBack: !enableDualView
                text: getDirName(filePath)
                onClicked: windowLoader.source = ""
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
}
