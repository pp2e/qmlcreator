import QtQuick
import QtQuick.Window

Item {
    id: touchItem

    property color color: Qt.rgba(Math.random(),
                                  Math.random(),
                                  Math.random())

    Rectangle {
        anchors.centerIn: parent

        width: 3 * Screen.logicalPixelDensity
        height: Screen.height * 2
        color: touchItem.color

        rotation: 45
    }

    Rectangle {
        anchors.centerIn: parent

        width: 3 * Screen.logicalPixelDensity
        height: Screen.height * 2
        color: touchItem.color

        rotation: -45
    }
}
