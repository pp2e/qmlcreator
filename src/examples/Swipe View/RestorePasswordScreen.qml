import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

SwipeScreen {
    onSelected: emailTextField.forceActiveFocus()

    ColumnLayout {
        anchors.centerIn: parent

        RowLayout {
            Label { text: "Email" }
            TextField {
                id: emailTextField
                Layout.fillWidth: true
            }
        }

        Button {
            Layout.fillWidth: true
            text: "Send instructions"
        }
    }
}
