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
import ProjectManager
import "../components"

BlankScreen {
    id: projectsScreen

    StackView.onStatusChanged: {
        if (StackView.status === StackView.Activating)
            listView.model = ProjectManager.files("Projects")
    }

    Component.onCompleted: {
        listView.model = ProjectManager.files("Projects")
    }

    CListView {
        id: listView
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.topMargin: toolBar.height

        delegate: CFileButton {
            width: listView.width
            text: modelData.name
            isDir: modelData.isDir
            onClicked: {
                // ProjectManager.subDir = ""
                // ProjectManager.projectName = modelData
                leftView.push(Qt.resolvedUrl("FilesScreen.qml"),
                              {
                                  subPath: "Projects" + "/" + modelData.name
                              })
            }
            onRemoveClicked: {
                var parameters = {
                    title: qsTr("Delete the project"),
                    text: qsTr("Are you sure you want to delete \"%1\"?").arg(modelData.name)
                }

                var callback = function(value)
                {
                    if (value)
                    {
                        ProjectManager.removeProject("Projects", modelData.name)
                        listView.model = ProjectManager.files("Projects")
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
                text: qsTr("Projects")
            }

            CToolButton {
                Layout.fillHeight: true
                icon: "\uf067"
                tooltipText: qsTr("New project")
                onClicked: {
                    var parameters = {
                        title: qsTr("New project")
                    }

                    var callback = function(value)
                    {
                        ProjectManager.createProject("Projects", value)
                        listView.model = ProjectManager.files("Projects")
                    }

                    dialog.open(dialog.types.newProject, parameters, callback)
                }
            }
        }
    }

    CToolBarBlur {
        sourceItem: listView
    }

    CScrollBar {
        flickableItem: listView
    }
}
