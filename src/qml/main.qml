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
import QtQuick.Controls.Material
import ScreenInsets
import WindowLoader
import ProjectManager
import "components"
import "components/dialogs"
import "screens"

// test if it will be linked
import Qt.labs.platform

CApplicationWindow {
    id: appWindow
    property alias splitView : splitView
    readonly property bool isDarkMode : settings.palette == "Dark"

    Material.theme: isDarkMode ?
                        Material.Dark :
                        Material.Light
    Material.accent: isDarkMode ?
                         Material.Red :
                         Material.Blue

    property var insets: ScreenInsets {
        window: Window.window
    }

    onBackPressed: {
        if (dialog.visible)
            dialog.close()
        else if (splitView.leftView.depth > 1 || splitView.rightView.depth > 1)
            splitView.popPage()
        else
            Qt.quit()
    }

    WindowLoader {
        id: windowLoader
        color: appWindow.colorPalette.background
    }

    CSplitView {
        id: splitView
        anchors.fill: parent
        anchors.bottomMargin: Qt.inputMethod.visible && platformResizesView ?
                                  (Qt.inputMethod.keyboardRectangle.height / (GRID_UNIT_PX / 8)) : 0

        Component.onCompleted: {
            splitView.leftView.push(Qt.resolvedUrl("screens/FilesScreen.qml"),
                                   {listFooter: mainMenuFooter,
                                    subPath: ProjectManager.baseFolderPath("")})
            splitView.rightView.push(initialRightView)
        }
        
        Component {
            id: mainMenuFooter
            Column {
                id: column
                width: parent.width

                // CNavigationButton {
                //     id: qrcButton
                //     text: qsTr("qrc:/")
                //     icon: "\uf0ad"
                //     onClicked: {
                //         splitView.leftView.push(Qt.resolvedUrl("screens/FilesScreen.qml"), {subPath: ":/"})
                //     }
                // }
                
                CNavigationButton {
                    id: settingsButton
                    text: qsTr("SETTINGS")
                    icon: "\uf0ad"
                    onClicked: {
                        splitView.rightView.push(Qt.resolvedUrl("screens/SettingsScreen.qml"))
                    }
                }

                CNavigationButton {
                    id: modulesButton
                    text: qsTr("MODULES")
                    icon: "\uf085"
                    onClicked: {
                        splitView.rightView.push(Qt.resolvedUrl("screens/ModulesScreen.qml"))
                    }
                }
                CNavigationButton {
                    id: aboutButton
                    text: qsTr("ABOUT")
                    icon: "\uf0e5"
                    onClicked: {
                        splitView.rightView.push(Qt.resolvedUrl("screens/AboutScreen.qml"))
                    }
                }
            }
        }

        Item {
            id: initialRightView

            Image {
                anchors.fill: parent
                anchors.margins: parent.width / 4
                visible: splitView.enableDualView
                fillMode: Image.PreserveAspectFit
                source: "qrc:/qt/qml/QmlCreator/resources/images/icon512.png"
            }
        }
    }

    DialogLoader {
        id: dialog
        anchors.fill: parent
    }

    CTooltip {
        id: tooltip
    }
}
