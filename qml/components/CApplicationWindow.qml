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
import ProjectManager
import "palettes"

ApplicationWindow {
    id: cApplicationWindow
    width: 420
    height: 640
    visible: true
    title: "QML Creator"
    //visibility: settings.debugMode ? "FullScreen" : "Maximized"
    background: Rectangle { color: appWindow.colorPalette.background }

    readonly property bool enableDualView: width > height

    // Loading
    signal loaded()

    Component.onCompleted:
        loaded()

    onLoaded: {
        // http://doc.qt.io/qt-5/qml-qtquick-window-screen.html
        // The Screen attached object is valid inside Item or Item derived types, after component completion
        // settings.pixelDensity = settings.debugMode ? 6.0 : Screen.logicalPixelDensity

        var previousVersion = parseInt(settings.previousVersion.split(".").join(""))
        if (previousVersion === 0)
        { // first run
            ProjectManager.restoreExamples("Examples")
            settings.previousVersion = Qt.application.version
        }
        else
        {
            var currentVersion = parseInt(Qt.application.version.split(".").join(""))
            if (currentVersion > previousVersion)
            {
                var parameters = {
                    title: qsTr("New examples"),
                    text: qsTr("We detected that you had recently updated QML Creator on your device.") + "\n" +
                          qsTr("We are constantly working on QML Creator improvement, and we may have added some new sample projects in the current release.") + "\n" +
                          qsTr("Press OK if you would like to get them now (notice that all the changes you have made in the Examples section will be removed)") + "\n" +
                          qsTr("Alternatively, you can do it later by pressing the Restore examples button in the Examples screen.")
                }

                var callback = function(value)
                {
                    if (value)
                        ProjectManager.restoreExamples("Examples")

                    settings.previousVersion = Qt.application.version
                }

                dialog.open(dialog.types.confirmation, parameters, callback)
            }
        }
    }

    // Settings
    QtObject {
        id: settings

        // configurable
        property string font: "Ubuntu Mono"
        property int fontSize: 20
        property string palette: "Cute"
        property int indentSize: 4
        property bool debugging: true
        property bool allowEditUI: false
        property bool useNewPlayground: true

        // internal
        property bool debugMode: false
        property double pixelDensity : 2.5
        property string previousVersion: "0.0.0"
        property bool desktopPlatform: Qt.platform.os === "windows" ||
                                       Qt.platform.os === "linux" ||
                                       Qt.platform.os === "osx" ||
                                       Qt.platform.os === "unix"
    }

    Settings {
        category: "Editor"
        property alias font: settings.font
        property alias fontSize: settings.fontSize
        property alias palette: settings.palette
        property alias indentSize: settings.indentSize
        property alias debugging: settings.debugging
        property alias allowEditUI: settings.allowEditUI
        property alias useNewPlayground: settings.useNewPlayground 
    }

    Settings {
        category: "Version"
        property alias previousVersion: settings.previousVersion
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
            source: "qrc:/QmlCreator/resources/fonts/editor/ubuntumono.ttf"
        }

        ListElement {
            name: "DejaVu Sans Mono"
            source: "qrc:/QmlCreator/resources/fonts/editor/dejavusansmono.ttf"
        }

        ListElement {
            name: "Liberation Mono"
            source: "qrc:/QmlCreator/resources/fonts/editor/liberationmono.ttf"
        }

        ListElement {
            name: "Droid Sans Mono"
            source: "qrc:/QmlCreator/resources/fonts/editor/droidsansmono.ttf"
        }

        ListElement {
            name: "Fira Mono"
            source: "qrc:/QmlCreator/resources/fonts/editor/firamono.ttf"
        }

        ListElement {
            name: "Source Code Pro"
            source: "qrc:/QmlCreator/resources/fonts/editor/sourcecodepro.ttf"
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
        source: "qrc:/QmlCreator/resources/fonts/ui/robotoregular.ttf"
    }

    FontLoader {
        source: "qrc:/QmlCreator/resources/fonts/ui/robotoitalic.ttf"
    }

    FontLoader {
        source: "qrc:/QmlCreator/resources/fonts/ui/robotobold.ttf"
    }

    FontLoader {
        source: "qrc:/QmlCreator/resources/fonts/ui/robotobolditalic.ttf"
    }

    FontLoader {
        source: "qrc:/QmlCreator/resources/fonts/ui/fontawesome.ttf"
    }
}
