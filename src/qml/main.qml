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
import QmlCreator
import "components"
import "components/dialogs"
import "screens"
import org.kde.kirigami as Kirigami

CApplicationWindow {
    id: appWindow
    minimumHeight: 100
    minimumWidth: 100
    flags: Qt.Window | Qt.MaximizeUsingFullscreenGeometryHint
    readonly property bool isDarkMode : settings.palette == "Dark"

    Material.theme: isDarkMode ?
                        Material.Dark :
                        Material.Light
    Material.accent: isDarkMode ?
                         Material.Red :
                         Material.Blue

    property var insets: ScreenInsets {
        window: appWindow
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
        hideWindow: true
        color: appWindow.colorPalette.background
    }

    pageStack.initialPage: FilesScreen {
        subPath: ProjectManager.baseFolderPath("")

        listFooter: Column {
            id: column
            width: parent.width

            // CNavigationButton {
            //     text: qsTr("qrc:/")
            //     icon: "\uf0ad"
            //     onClicked: {
            //         splitView.leftView.push(Qt.resolvedUrl("screens/FilesScreen.qml"), {subPath: ":/"})
            //     }
            // }

            CNavigationButton {
                text: qsTr("SETTINGS")
                icon: "\uf0ad"
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("screens/SettingsScreen.qml"))
                }
            }

            CNavigationButton {
                text: qsTr("MODULES")
                icon: "\uf085"
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("screens/ModulesScreen.qml"))
                }
            }
            CNavigationButton {
                text: qsTr("ABOUT")
                icon: "\uf0e5"
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("screens/AboutScreen.qml"))
                }
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
