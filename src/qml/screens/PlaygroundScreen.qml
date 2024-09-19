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

BlankScreen {
    id: playgroundScreen
    enabled: true

    property string path: ""

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

    CToolBar {
        id: toolBar

        RowLayout {
            anchors.fill: parent
            spacing: 0

            CBackButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                //enabled: !leftView.busy
                //enableBack: !enableDualView
                text: getDirName(path)
            }

            CToolButton {
                Layout.fillHeight: true
                icon: "\uf188"
                tooltipText: settings.debugging ? qsTr("Disable debugging") : qsTr("Enable debugging")
                checked: settings.debugging
                onClicked: {
                    settings.debugging = !settings.debugging
                }
            }
        }
    }

    Item {
        id: playArea
        anchors.top: toolBar.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
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
            // onMessageReceived:
            //     messages.append(message)
            function onMessageReceived(message) {
                messages.append(message)
            }
        }
    }

    property var obj
    Component.onCompleted: {
        var componentUrl = ProjectManager.getFilePath(path)
        var playComponent = Qt.createComponent(componentUrl, Component.PreferSynchronous)
        if (playComponent.status === Component.Error)
        {
            messages.append(playComponent.errorString())
        }
        else
        {
            obj = playComponent.createObject(playArea)
        }
    }

    Component.onDestruction: {
        if (obj)
            obj.destroy()
    }
}
