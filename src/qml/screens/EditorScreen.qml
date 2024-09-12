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
    id: editorScreen
    padding: 0

    property alias codeArea : codeArea
    property string filePath: ""

    function saveContent() {
        console.log("save")
        ProjectManager.saveFileContent(filePath, codeArea.text)
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

    title: getDirName(filePath)
    actions: [
        Kirigami.Action {
            icon.name: "edit-select-all"
            text: qsTr("Select all")
            visible: codeArea.selectedText.length > 0 && !codeArea.useNativeTouchHandling
            onTriggered: codeArea.selectAll()
        },
        Kirigami.Action {
            icon.name: "edit-copy"
            text: qsTr("Copy")
            visible: codeArea.selectedText.length > 0 && !codeArea.useNativeTouchHandling
            onTriggered: codeArea.copy()
        },
        Kirigami.Action {
            icon.name: "edit-cut"
            text: qsTr("Cut")
            visible: codeArea.selectedText.length > 0 && !codeArea.useNativeTouchHandling
            onTriggered: codeArea.cut()
        },
        Kirigami.Action {
            icon.name: "media-playback-start"
            text: qsTr("Run")
            visible: filePath.endsWith(".qml") &&
                                           (!codeArea.selectedText.length > 0 || codeArea.useNativeTouchHandling)
            onTriggered: {
                ProjectManager.saveFileContent(filePath, codeArea.text)
                ProjectManager.clearComponentCache()
                Qt.inputMethod.hide()
                var playgroundName = settings.useNewPlayground ? "NewPlaygroundScreen.qml" : "PlaygroundScreen.qml"
                pageStack.push(Qt.resolvedUrl(playgroundName), {filePath : filePath})
            }
        }
    ]

    onIsCurrentPageChanged: {
        if (isCurrentPage) {
            codeArea.text = ProjectManager.getFileContent(filePath);
        } else {
            saveContent()
        }
    }

    CCodeArea {
        id: codeArea

        anchors.fill: parent

        indentSize: settings.indentSize
    }
}
