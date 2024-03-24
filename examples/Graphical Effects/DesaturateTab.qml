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
        source: "qrc:/QmlCreator/resources/images/icon512.png"
    }

    Desaturate {
        id: effect
        anchors.fill: image
        source: image
        desaturation: desaturationSlider.value
    }

    GridLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: columnSpacing
        columns: 2

        Label { text: "Desaturation" }
        Slider {
            id: desaturationSlider
            Layout.fillWidth: true
            minimumValue: 0
            maximumValue: 1
            value: 1
        }
    }
}
