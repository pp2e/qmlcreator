import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

SwipeScreen {
    onSelected: usernameTextField.forceActiveFocus()

    ColumnLayout {
        anchors.centerIn: parent

        GridLayout {
            columns: 2

            Label { text: "Username" }
            TextField {
                id: usernameTextField
                Layout.fillWidth: true
            }

            Label { text: "Password" }
            TextField {
                Layout.fillWidth: true
                echoMode: TextInput.Password
            }
        }

        CheckBox {
            Layout.fillWidth: true
            text: "Remember me"
        }

        Button {
            Layout.fillWidth: true
            text: "Log In"
        }
    }
}
