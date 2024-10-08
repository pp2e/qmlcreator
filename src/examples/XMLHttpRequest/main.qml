import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    anchors.fill: parent

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: spacing

        RowLayout {
            TextField {
                id: hostTextField
                Layout.fillWidth: true
                Layout.minimumHeight: 80
                text: "http://www.whatismyip.com/"
            }

            Item {
                Layout.fillWidth: true
            }

            Button {
                Layout.minimumHeight: 80
                text: "Send request"

                onClicked: {
                    var request = new XMLHttpRequest()
                    request.open("GET", hostTextField.text)
                    request.onreadystatechange = function () {
                        if (request.readyState === XMLHttpRequest.DONE) {
                            if (request.status === 200) {
                                responseTextArea.text = request.responseText
                            } else {
                                responseTextArea.text = "HTTP request failed " + request.status
                            }
                        }
                    }
                    request.send()
                }
            }
        }

        TextArea {
            id: responseTextArea
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
