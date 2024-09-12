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
import "../components"
import QmlCreator

import org.kde.kirigami as Kirigami

Kirigami.Page {
    id: mainMenuScreen
    padding: 0

    title: qsTr("Settings")

    CFlickable {
        id: settingsFlickable
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            anchors.left: parent.left
            anchors.right: parent.right

            CSettingButton {
                text: qsTr("Font family")
                description: settings.font
                onClicked: {
                    var parameters = {
                        title: qsTr("Editor font"),
                        model: editorFonts,
                        currentIndex: editorFonts.getCurrentIndex()
                    }

                    var callback = function(value) {
                        settings.font = editorFonts.get(value).name
                    }

                    dialog.open(dialog.types.fontFamily, parameters, callback)
                }
            }

            CSettingButton {
                text: qsTr("Font size")
                description: settings.fontSize.toString() + " px"

                onClicked: {
                    var parameters = {
                        title: qsTr("Font size"),
                        text: "Preview",
                        minSize: 10,
                        maxSize: 120,
                        currentSize: settings.fontSize
                    }

                    var callback = function(value) {
                        if (value < 1) return

                        if (value < parameters.minSize)
                            settings.fontSize = parameters.minSize;
                        else if (value > parameters.maxSize)
                            settings.fontSize = parameters.maxSize;
                        else
                            settings.fontSize = value;
                    }

                    dialog.open(dialog.types.fontSize, parameters, callback)
                }
            }

            CSettingButton {
                text: qsTr("Indent size")
                description: settings.indentSize.toString()

                onClicked: {
                    var parameters = {
                        title: qsTr("Indent size"),
                        minSize: 0,
                        maxSize: 4,
                        currentSize: settings.indentSize
                    }

                    var callback = function(value) {
                        if (value < parameters.minSize)
                            settings.indentSize = parameters.minSize;
                        else if (value > parameters.maxSize)
                            settings.indentSize = parameters.maxSize;
                        else
                            settings.indentSize = value;
                    }

                    dialog.open(dialog.types.indentSize, parameters, callback)
                }
            }

            CSettingButton {
                text: qsTr("Debugging")
                description: settings.debugging ? qsTr("Enabled") : qsTr("Disabled")

                onClicked: {
                    settings.debugging = !settings.debugging
                }
            }
            
            CSettingButton {
                text: qsTr("Use new playground")
                description: settings.useNewPlayground ? qsTr("Enabled") : qsTr("Disabled")

                onClicked: {
                    settings.useNewPlayground = !settings.useNewPlayground
                }
            }

            CSettingButton {
                text: qsTr("Palette")
                description: settings.palette
                onClicked: {
                    var parameters = {
                        title: qsTr("Palette"),
                        model: palettes,
                        currentIndex: palettes.getCurrentIndex()
                    }

                    var callback = function(value) {
                        settings.palette = palettes.get(value).name
                    }

                    dialog.open(dialog.types.list, parameters, callback)
                }
            }
            
            CSettingButton {
                text: qsTr("Restore the examples")
                onClicked: {
                    var parameters = {
                        title: qsTr("Restore the examples"),
                        text: qsTr("Press OK to delete all the edits you have made in the Examples section.")
                    }

                    var callback = function(value)
                    {
                        if (value)
                        {
                            ProjectManager.restoreExamples(ProjectManager.baseFolderPath("Examples"))
                        }
                    }

                    dialog.open(dialog.types.confirmation, parameters, callback)
                }
            }

            CSettingButton {
                text: qsTr("QML entry point")
                description: settings.qmlEntryPoint !== "" ? settings.qmlEntryPoint : "Builtin"
                onClicked: {
                    if (settings.qmlEntryPoint === "") return;

                    var parameters = {
                        title: qsTr("Reset QML entry point?"),
                        text: qsTr("You will load from builtin on restart")
                    }

                    var callback = function(value)
                    {
                        if (value)
                        {
                            settings.qmlEntryPoint = ""
                        }
                    }

                    dialog.open(dialog.types.confirmation, parameters, callback)
                }
            }
            
            CSettingButton {
                text: qsTr("Restore QML Creator files")
                onClicked: {
                    var parameters = {
                        title: qsTr("Restore QML Creator files"),
                        text: qsTr("Press OK to delete all the edits you have made in QML Creator ui.")
                    }

                    var callback = function(value)
                    {
                        if (value)
                        {
                            ProjectManager.restoreQmlFiles(ProjectManager.baseFolderPath("QmlCreator"))
                            settings.qmlEntryPoint = ProjectManager.baseFolderPath("QmlCreator")+"/main.qml"
                        }
                    }

                    dialog.open(dialog.types.confirmation, parameters, callback)
                }
            }
        }
    }

    CScrollBar {
        flickableItem: settingsFlickable
    }

    ListModel {
        id: palettes

        ListElement {
            name: "Cute"
            source: "CutePalette.qml"
        }

        ListElement {
            name: "Light"
            source: "LightPalette.qml"
        }

        ListElement {
            name: "Dark"
            source: "DarkPalette.qml"
        }

        function getCurrentIndex() {
            for (var i = 0; i < count; i++)
            {
                if (get(i).name === settings.palette)
                    return i;
            }

            return -1;
        }
    }
}
