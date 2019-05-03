import QtQuick 2.5
import QtQuick.Controls 2.0

TabView {
    anchors.fill: parent

    Tab {
        title: "Color"
        ColorDialogTab {}
    }

    Tab {
        title: "Message"
        MessageDialogTab {}
    }
}
