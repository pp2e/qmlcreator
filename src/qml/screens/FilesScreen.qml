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
import QtQuick.Layouts
import QmlCreator
import "../components"

BlankScreen {
    id: projectsScreen
    
    property string path : ""
    property alias listFooter: listView.footer

    StackView.onStatusChanged: {
        if (StackView.status === StackView.Activating) {
            // ProjectManager.subDir = projectsScreen.subPath
            listView.model = ProjectManager.files(projectsScreen.path)
        }
    }

    function getDirName(path) {
        var dirname = ""
        var dirs = path.split("/")
        if(dirs.length > 0) {
            dirname = dirs[dirs.length - 1]
        } else {
            dirname = ""
        }
        return dirname
    }


    ListView {
        id: listView
        anchors.top: toolBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: appWindow.insets.bottom
        displayMarginBeginning: toolBar.height
        displayMarginEnd: anchors.bottomMargin

        ScrollIndicator.vertical: ScrollIndicator {}

        delegate: CFileButton {
            width: listView.width
            text: modelData.name
            // removeButtonVisible: modelData.name !== "main.qml"
            isDir: modelData.isDir

            onClicked: {
                var newScreen = null;

                while (rightView.depth > 1) {
                    rightView.pop()
                }

                if (modelData.isDir) {
                    leftView.push(Qt.resolvedUrl("FilesScreen.qml"), {path : modelData.fullPath})
                } else {
                    rightView.push(Qt.resolvedUrl("EditorScreen.qml"), {path : modelData.fullPath})
                }

            }

            onRemoveClicked: {
                var parameters = {
                    title: qsTr("Delete the file"),
                    text: qsTr("Are you sure you want to delete \"%1\"?").arg(modelData.name)
                }

                var callback = function(value)
                {
                    if (value)
                    {
                        ProjectManager.removeFile(modelData.fullPath)
                        listView.model = ProjectManager.files(path)
                    }
                }

                dialog.open(dialog.types.confirmation, parameters, callback)
            }
        }
    }

    CToolBar {
        id: toolBar

        RowLayout {
            anchors.fill: parent
            spacing: 0

            CBackButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                enableBack: leftView.depth > 1
                targetSplit: leftView
                text: getDirName(path)
            }

            CToolButton {
                Layout.fillHeight: true
                icon: "\uf067"
                tooltipText: qsTr("New...")
                onClicked: newContextMenu.open()
            }
        }
    }

    Menu {
        id: newContextMenu
        x: parent.width - width
        y: toolBar.height
        MenuItem {
            text: qsTr("New file...")
            onTriggered: {
                var parameters = {
                    title: qsTr("New file"),
                    path: path,
                }

                var callback = function(value)
                {
                    ProjectManager.createFile(path + "/" + value.fileName, value.fileExtension)
                    listView.model = ProjectManager.files(path)
                }

                dialog.open(dialog.types.newFile, parameters, callback)
            }
        }

        MenuItem {
            text: qsTr("New directory...")
            onTriggered: {
                var parameters = {
                    title: qsTr("New directory"),
                    path: path,
                }

                var callback = function(value)
                {
                    ProjectManager.createDir(path + "/" + value.dirName)
                    listView.model = ProjectManager.files(path)
                }

                dialog.open(dialog.types.newDir, parameters, callback)
            }
        }

        MenuItem {
            text: qsTr("New project...")
            onTriggered: {
                var parameters = {
                    title: qsTr("New project"),
                    path: path,
                }

                var callback = function(value)
                {
                    ProjectManager.createProject(path, value)
                    listView.model = ProjectManager.files(path)
                }

                dialog.open(dialog.types.newProject, parameters, callback)
            }
        }
    }

    CToolBarBlur {
        sourceItem: listView
    }
}
