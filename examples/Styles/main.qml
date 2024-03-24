import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

Item {
    anchors.fill: parent

    GridLayout {
        anchors.fill: parent

        columns: 2

        BusyIndicator {
            id: normalIndicator
            Layout.alignment: Qt.AlignCenter
        }
        BusyIndicator {
            id: styledIndicator
            Layout.alignment: Qt.AlignCenter
            style: SBusyIndicatorStyle {}
        }

        Button {
            Layout.alignment: Qt.AlignCenter
            text: "Normal"
            onClicked:
                normalIndicator.running = !normalIndicator.running
        }
        Button {
            Layout.alignment: Qt.AlignCenter
            text: "Styled"
            style: SButtonStyle {}
            onClicked:
                styledIndicator.running = !styledIndicator.running
        }
    }
}
