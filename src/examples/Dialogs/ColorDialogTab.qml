import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs

Item {
    anchors.fill: parent

    Rectangle {
        id: rect
        anchors.fill: parent
    }

    Button {
        anchors.centerIn: parent
        text: "Show dialog"
        onClicked: dialog.visible = true
    }

    ColorDialog {
        id: dialog
        onAccepted: rect.color = color
    }
}
