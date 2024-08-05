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
    id: editorScreen
    objectName: "EditorScreen"

    function saveContent() {
        // ProjectManager.fileName = fileName
        ProjectManager.saveFileContent(filePath, codeArea.text)
    }

    property alias codeArea : codeArea
    property string filePath: ""

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

    StackView.onStatusChanged: {
        if (StackView.status === StackView.Activating) {
            // ProjectManager.fileName = fileName
            codeArea.text = ProjectManager.getFileContent(filePath);
        } else if (StackView.status === StackView.Deactivating) {
            saveContent()
        }
    }



    CCodeArea {
        id: codeArea

        anchors.top: toolBar.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        indentSize: settings.indentSize

        text: ""
    }

    CToolBar {
        id: toolBar

        RowLayout {
            anchors.fill: parent
            spacing: 0

            CBackButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: getDirName(filePath)
                //enableBack: !enableDualView
                targetSplit: appWindow.splitView.rightView
                onClicked: {
                    saveContent()
                }
            }

            CToolButton {
                visible: codeArea.selectedText.length > 0 && !codeArea.useNativeTouchHandling
                Layout.fillHeight: true
                icon: "\uf034"
                tooltipText: qsTr("Select all")
                onClicked: codeArea.selectAll()
            }

            CToolButton {
                visible: codeArea.selectedText.length > 0 && !codeArea.useNativeTouchHandling
                Layout.fillHeight: true
                icon: "\uf0c5"
                tooltipText: qsTr("Copy")
                onClicked: codeArea.copy()
            }

            CToolButton {
                visible: codeArea.selectedText.length > 0 && !codeArea.useNativeTouchHandling
                Layout.fillHeight: true
                icon: "\uf0c4"
                tooltipText: qsTr("Cut")
                onClicked: codeArea.cut()
            }

            CToolButton {
                visible: filePath.endsWith(".qml") &&
                         (!codeArea.selectedText.length > 0 || codeArea.useNativeTouchHandling)
                Layout.fillHeight: true
                icon: "\uf04b"
                tooltipText: qsTr("Run")
                onClicked: {
                    ProjectManager.saveFileContent(filePath, codeArea.text)
                    ProjectManager.clearComponentCache()
                    Qt.inputMethod.hide()
                    var playgroundName = settings.useNewPlayground ? "NewPlaygroundScreen.qml" : "PlaygroundScreen.qml"
                    var playgroundScreenComponent = Qt.createComponent(Qt.resolvedUrl(playgroundName),
                                       Component.PreferSynchronous);
                    var newScreen = playgroundScreenComponent.createObject(rightView,
                                                               {
                                                                   filePath : filePath,
                                                               });
                    rightView.push(newScreen)
                }
            }
        }
    }

    CToolBarBlur {
        sourceItem: codeArea
    }
}