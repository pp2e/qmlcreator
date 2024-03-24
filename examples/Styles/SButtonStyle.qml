import QtQuick
import QtQuick.Controls.Styles
import QtQuick.Window
import QtGraphicalEffects

ButtonStyle {
    background: Item {
        implicitWidth: 35 * Screen.logicalPixelDensity
        implicitHeight: 15 * Screen.logicalPixelDensity

        Rectangle {
            id: bottomRect
            anchors.fill: parent
            anchors.topMargin: radius
            radius: parent.height / 15
            color: "#006325"
        }

        Rectangle {
            anchors.fill: parent
            anchors.bottomMargin: radius
            color: "#80c342"
            radius: bottomRect.radius
            visible: !control.pressed
        }
    }

    label: Text {
        anchors.fill: parent
        anchors.leftMargin: height / 5
        anchors.rightMargin: height / 5
        anchors.topMargin: control.pressed ? parent.height / 15 : 0
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: "#ffffff"
        text: control.text
        font.pixelSize: 5 * Screen.logicalPixelDensity
        elide: Text.ElideRight
    }
}
