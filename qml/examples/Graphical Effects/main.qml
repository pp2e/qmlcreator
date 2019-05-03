import QtQuick 2.5
import QtQuick.Controls 2.0

TabView {
    anchors.fill: parent

    Tab {
        title: "Brightness contrast"
        BrightnessContrastTab {}
    }

    Tab {
        title: "Desaturate"
        DesaturateTab {}
    }

    Tab {
        title: "Directional Blur"
        DirectionalBlurTab {}
    }
}
