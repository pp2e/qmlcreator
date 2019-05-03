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

import QtQuick 2.5
import QtQuick.Controls 2.0
import ProjectManager 1.1
import "../components"

BlankScreen {
    id: mainMenuScreen

    StackView.onStatusChanged: {
        if (StackView.status === StackView.Activating)
            column.setLocked(null)
    }

    property var splitView : null

    CToolBar {
        id: toolBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        CBackButton {
            anchors.fill: parent
            text: appWindow.title
            enableBack: appWindow.splitView.rightView.depth > 1
            targetSplit: appWindow.splitView.rightView
            onClicked: column.setLocked(null)
        }
    }

    CFlickable {
        id: menuFlickable
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: toolBar.bottom
        anchors.bottom: parent.bottom
        contentHeight: column.height

        Column {
            id: column
            anchors.left: parent.left
            anchors.right: parent.right

            function setLocked(buttonView) {
                projectsButton.locked = false
                examplesButton.locked = false
                settingsButton.locked = false
                modulesButton.locked = false
                aboutButton.locked = false
                if (buttonView)
                    buttonView.locked = true
            }

            CNavigationButton {
                id: projectsButton
                text: qsTr("PROJECTS")
                icon: "\uf0f6"
                onClicked: {
                    column.setLocked(projectsButton)
                    ProjectManager.baseFolder = ProjectManager.Projects
                    splitView.leftView.push(Qt.resolvedUrl("ProjectsScreen.qml"))
                }
            }

            CNavigationButton {
                id: examplesButton
                text: qsTr("EXAMPLES")
                icon: "\uf1c9"
                onClicked: {
                    column.setLocked(examplesButton)
                    ProjectManager.baseFolder = ProjectManager.Examples
                    splitView.leftView.push(Qt.resolvedUrl("ExamplesScreen.qml"))
                }
            }

            CNavigationButton {
                id: settingsButton
                text: qsTr("SETTINGS")
                icon: "\uf0ad"
                onClicked: {
                    column.setLocked(settingsButton)
                    splitView.rightView.push(Qt.resolvedUrl("SettingsScreen.qml"))
                }
            }

            CNavigationButton {
                id: modulesButton
                text: qsTr("MODULES")
                icon: "\uf085"
                onClicked: {
                    column.setLocked(modulesButton)
                    splitView.rightView.push(Qt.resolvedUrl("ModulesScreen.qml"))
                }
            }

            CNavigationButton {
                id: aboutButton
                text: qsTr("ABOUT")
                icon: "\uf0e5"
                onClicked: {
                    column.setLocked(aboutButton)
                    splitView.rightView.push(Qt.resolvedUrl("AboutScreen.qml"))
                }
            }
        }
    }

    CScrollBar {
        flickableItem: menuFlickable
    }
}

