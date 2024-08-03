import QtQuick
import QtQuick.Effects

MultiEffect {
    id: fastBlur
    height: 22 * settings.pixelDensity + appWindow.insets.top
    width: parent.width
    blurEnabled: true
    blur: 1
    blurMax: 40
    opacity: 0.55
    autoPaddingEnabled: false

    property alias sourceItem: source.sourceItem

    source: ShaderEffectSource {
        id: source
        sourceItem: menuFlickable
        sourceRect: Qt.rect(0, -fastBlur.height, fastBlur.width, fastBlur.height)
    }
}
