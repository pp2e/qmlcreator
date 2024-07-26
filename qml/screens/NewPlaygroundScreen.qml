import QtQuick
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

    Component.onCompleted: windowLoader.source = ProjectManager.getFilePath(filePath)

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

            MouseArea {
                width: 40
                Layout.fillHeight: true
                onClicked: windowLoader.source = ""
            }
        }
    }

    WindowContainer {
        anchors.top: toolBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        window: windowLoader.window
        onWidthChanged: console.log(window)
    }
}
