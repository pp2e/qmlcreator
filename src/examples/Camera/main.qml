import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia

Item {
    id: root
    anchors.fill: parent
    property var cameras: QtMultimedia.availableCameras
    property int currentCamera: 0

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: spacing

        VideoOutput {
            Layout.fillWidth: true
            Layout.fillHeight: true
            source: Camera { id: camera }
            autoOrientation: true
        }

        RowLayout {
            Label {
                Layout.fillWidth: true
                text: camera.displayName
            }

            Button {
                visible: cameras.length > 1
                text: "Change camera"
                onClicked: {
                    currentCamera++
                    if (currentCamera >= cameras.length)
                        currentCamera = 0
                    camera.deviceId = cameras[currentCamera].deviceId
                }
            }
        }
    }
}
