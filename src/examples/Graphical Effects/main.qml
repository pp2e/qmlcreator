import QtQuick
import QtQuick.Controls

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
