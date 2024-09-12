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

import org.kde.kirigami as Kirigami

Kirigami.Page {
    id: projectsScreen
    padding: 0
    
    property string subPath : ""
    property alias listFooter: listView.footer

    title: getDirName(subPath)
    actions: [
        Kirigami.Action {
            icon.name: "list-add"
            text: qsTr("Add...")

            Kirigami.Action {
                icon.name: "document-new"
                text: qsTr("New file...")
                onTriggered: {
                    var parameters = {
                        title: qsTr("New file"),
                        path: subPath,
                    }

                    var callback = function(value)
                    {
                        ProjectManager.createFile(subPath + "/" + value.fileName, value.fileExtension)
                        listView.model = ProjectManager.files(subPath)
                    }

                    dialog.open(dialog.types.newFile, parameters, callback)
                }
            }
            Kirigami.Action {
                icon.name: "folder-new"
                text: qsTr("New directory...")
                onTriggered: {
                    var parameters = {
                        title: qsTr("New directory"),
                        path: subPath,
                    }

                    var callback = function(value)
                    {
                        ProjectManager.createDir(subPath + "/" + value.dirName)
                        listView.model = ProjectManager.files(subPath)
                    }

                    dialog.open(dialog.types.newDir, parameters, callback)
                }
            }
            Kirigami.Action {
                icon.name: "project-development-new"
                text: qsTr("New project...")
                onTriggered: {
                    var parameters = {
                        title: qsTr("New project"),
                        path: subPath,
                    }

                    var callback = function(value)
                    {
                        ProjectManager.createProject(subPath, value)
                        listView.model = ProjectManager.files(subPath)
                    }

                    dialog.open(dialog.types.newProject, parameters, callback)
                }
            }
        }
    ]

    onIsCurrentPageChanged: {
        if (isCurrentPage)
            listView.model = ProjectManager.files(projectsScreen.subPath)
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


    CListView {
        id: listView
        anchors.fill: parent

        delegate: CFileButton {
            width: listView.width
            text: modelData.name
            isDir: modelData.isDir

            onClicked: {
                var newScreen = null;

                if (modelData.isDir) {
                    pageStack.push(Qt.resolvedUrl("FilesScreen.qml"), {subPath: modelData.fullPath})
                } else {
                    pageStack.push(Qt.resolvedUrl("EditorScreen.qml"), {filePath: modelData.fullPath})
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
                        listView.model = ProjectManager.files(subPath)
                    }
                }

                dialog.open(dialog.types.confirmation, parameters, callback)
            }
        }
    }

    CScrollBar {
        flickableItem: listView
    }
}
