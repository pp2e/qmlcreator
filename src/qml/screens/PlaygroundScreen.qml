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
import QtQuick.Layouts
import QmlCreator
import "../components"

import org.kde.kirigami as Kirigami

Kirigami.Page {
    id: playgroundScreen
    padding: 0

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

    title: getDirName(filePath)
    actions: [
        Kirigami.Action {
            icon.name: "showinfo"
            checkable: true
            checked: settings.debugging
            text: qsTr("Debug")
            tooltip: settings.debugging ? qsTr("Disable debugging") : qsTr("Enable debugging")
            onTriggered: settings.debugging = !settings.debugging
        }
    ]

    Item {
        id: playArea
        anchors.fill: parent
        clip: true

        Flickable {
            id: messagesFlickable
            z: 2
            anchors.fill: parent
            anchors.margins: 3 * settings.pixelDensity
            contentWidth: messages.paintedWidth
            contentHeight: messages.paintedHeight
            enabled: false

            function scrollDown() {
                if (contentHeight > height)
                    contentY = contentHeight - height
            }

            TextEdit {
                id: messages
                width: messagesFlickable.width
                height: messagesFlickable.height
                visible: settings.debugging
                color: appWindow.colorPalette.editorNormal
                opacity: 0.3
                font.pixelSize: 6 * settings.pixelDensity
                wrapMode: TextEdit.Wrap
                readOnly: true

                onTextChanged:
                    messagesFlickable.scrollDown()
            }
        }

        Connections {
            target: messageHandler
            function onMessageReceived(message) {
                messages.append(message)
            }
        }
    }

    Component.onCompleted: {
        var componentUrl = ProjectManager.getFilePath(filePath)
        var playComponent = Qt.createComponent(componentUrl, Component.PreferSynchronous)
        if (playComponent.status === Component.Error)
        {
            messages.append(playComponent.errorString())
        }
        else
        {
            playComponent.createObject(playArea)
        }
    }
}
