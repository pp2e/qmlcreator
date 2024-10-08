import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtGraphicalEffects

Item {
    anchors.fill: parent

    Image {
        id: image
        width: Math.min(parent.width, parent.height) * 0.7
        height: width
        anchors.centerIn: parent
        source: "qrc:/qt/qml/QmlCreator/resources/images/icon512.png"
    }

    DirectionalBlur {
        id: effect
        anchors.fill: image
        source: image
        transparentBorder: true
        angle: angleSlider.value
        length: lengthSlider.value
        samples: samplesSlider.value
    }

    GridLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: columnSpacing
        columns: 2

        Label { text: "Angle" }
        Slider {
            id: angleSlider
            Layout.fillWidth: true
            minimumValue: 0
            maximumValue: 360
            value: 180
        }

        Label { text: "Length" }
        Slider {
            id: lengthSlider
            Layout.fillWidth: true
            minimumValue: 0
            maximumValue: 100
            value: 100
        }

        Label { text: "Samples" }
        Slider {
            id: samplesSlider
            Layout.fillWidth: true
            minimumValue: 0
            maximumValue: 30
            value: 30
        }
    }
}
