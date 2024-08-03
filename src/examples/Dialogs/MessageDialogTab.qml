import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs

Item {
    anchors.fill: parent

    Button {
        anchors.centerIn: parent
        text: "Show dialog"
        onClicked: dialog.visible = true
    }

    MessageDialog {
        id: dialog
        title: "Breaking News!"
        text: "QML Creator is now available on App Store!"
    }
}
