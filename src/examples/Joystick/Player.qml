import QtQuick
import QtQuick.Window

Rectangle {
    id: player

    width: 20 * Screen.logicalPixelDensity
    height: width

    radius: width / 2
    color: "#006325"

    property double speed: 2 * Screen.logicalPixelDensity
}
