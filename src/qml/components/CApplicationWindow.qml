/****************************************************************************
**
** Copyright (C) 2013-2015 Oleg Yadrov
**
** Licensed under the Apache License, Version 2.0 (the "License");
** you may not use this file except in compliance with the License.
** You may obtain a copy of the License at
**
** http://www.apache.org/licenses/LICENSE-2.0
**
** Unless required by applicable law or agreed to in writing, software
** distributed under the License is distributed on an "AS IS" BASIS,
** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
** See the License for the specific language governing permissions and
** limitations under the License.
**
****************************************************************************/

import QtQuick
import QtQuick.Controls
import QtQuick.Window
// import Qt.labs.settings
import QtCore
import QmlCreator
import "palettes"

ApplicationWindow {
    id: cApplicationWindow
    width: 420
    height: 640
    visible: true
    title: "QML Creator"
    color: appWindow.colorPalette.background

    readonly property bool enableDualView: width > height

    // Settings
    QtObject {
        id: settings

        // configurable
        property string font: "Ubuntu Mono"
        property int fontSize: 20
        property string palette: "Cute"
        property int indentSize: 4
        property bool debugging: true
        property bool useNewPlayground: true
        property string qmlEntryPoint: ""

        // internal
        property bool debugMode: false
        property double pixelDensity : 2.5
        property bool desktopPlatform: Qt.platform.os === "windows" ||
                                       Qt.platform.os === "linux" ||
                                       Qt.platform.os === "osx" ||
                                       Qt.platform.os === "unix"
    }

    Settings {
        location: ProjectManager.settingsPath
        // category: "Editor"
        property alias font: settings.font
        property alias fontSize: settings.fontSize
        property alias palette: settings.palette
        property alias indentSize: settings.indentSize
        property alias debugging: settings.debugging
        property alias useNewPlayground: settings.useNewPlayground 
        property alias qmlEntryPoint: settings.qmlEntryPoint
    }

    property alias settings: settings

    // Palettes

    PaletteLoader {
        id: paletteLoader
        name: settings.palette
    }

    property alias colorPalette: paletteLoader.palette

    // Message Handler

    QtObject {
        id: messageHandler
        objectName: "messageHandler"
        signal messageReceived(string message)
    }

    property alias messageHandler: messageHandler

    // Focus Management

    property Item focusItem: null
    signal backPressed()

    onActiveFocusItemChanged: {
        if (focusItem !== null && focusItem.Keys !== undefined)
            focusItem.Keys.onReleased.disconnect(onKeyReleased)

        if (activeFocusItem !== null)
        {
            activeFocusItem.Keys.onReleased.connect(onKeyReleased)
            focusItem = activeFocusItem
        }
    }

    function onKeyReleased(event) {
        if (event.key === Qt.Key_Back || event.key === Qt.Key_Escape) {
            if (Qt.inputMethod.visible)
                Qt.inputMethod.hide()
            else
                backPressed()

            event.accepted = true
        }
    }

    // Editor Fonts

    property ListModel editorFonts: ListModel {
        ListElement {
            name: "Ubuntu Mono"
            source: "qrc:/qt/qml/QmlCreator/resources/fonts/editor/ubuntumono.ttf"
        }

        ListElement {
            name: "DejaVu Sans Mono"
            source: "qrc:/qt/qml/QmlCreator/resources/fonts/editor/dejavusansmono.ttf"
        }

        ListElement {
            name: "Liberation Mono"
            source: "qrc:/qt/qml/QmlCreator/resources/fonts/editor/liberationmono.ttf"
        }

        ListElement {
            name: "Droid Sans Mono"
            source: "qrc:/qt/qml/QmlCreator/resources/fonts/editor/droidsansmono.ttf"
        }

        ListElement {
            name: "Fira Mono"
            source: "qrc:/qt/qml/QmlCreator/resources/fonts/editor/firamono.ttf"
        }

        ListElement {
            name: "Source Code Pro"
            source: "qrc:/qt/qml/QmlCreator/resources/fonts/editor/sourcecodepro.ttf"
        }

        function getCurrentIndex() {
            for (var i = 0; i < count; i++)
            {
                if (get(i).name === settings.font)
                    return i;
            }

            return -1;
        }
    }

    Repeater {
        model: editorFonts
        delegate: Loader {
            sourceComponent: FontLoader {
                source: model.source
            }
        }
    }

    // UI Fonts

    FontLoader {
        source: "qrc:/qt/qml/QmlCreator/resources/fonts/ui/robotoregular.ttf"
    }

    FontLoader {
        source: "qrc:/qt/qml/QmlCreator/resources/fonts/ui/robotoitalic.ttf"
    }

    FontLoader {
        source: "qrc:/qt/qml/QmlCreator/resources/fonts/ui/robotobold.ttf"
    }

    FontLoader {
        source: "qrc:/qt/qml/QmlCreator/resources/fonts/ui/robotobolditalic.ttf"
    }

    FontLoader {
        source: "qrc:/qt/qml/QmlCreator/resources/fonts/ui/fontawesome.ttf"
    }
}
