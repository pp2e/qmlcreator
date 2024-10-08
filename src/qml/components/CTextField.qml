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

Item {
    id: cTextField

    implicitHeight: 14 * settings.pixelDensity

    anchors.left: parent.left
    anchors.right: parent.right

    property alias text: textInput.text
    property alias placeholder: placeholderTextInput.text
    property alias validator: textInput.validator

    Rectangle {
        anchors.fill: parent
        color: appWindow.colorPalette.textFieldBackground
        border.width: Math.max(1, Math.round(0.3 * settings.pixelDensity))
        border.color: appWindow.colorPalette.textFieldBorder
    }

    TextInput {
        id: placeholderTextInput
        anchors.fill: parent
        anchors.leftMargin: 4 * settings.pixelDensity
        anchors.rightMargin: 4 * settings.pixelDensity
        font.family: "Roboto"
        font.pixelSize: 6 * settings.pixelDensity
        verticalAlignment: Text.AlignVCenter
        color: appWindow.colorPalette.textFieldPlaceholder
        readOnly: true
        visible: textInput.length === 0
    }

    TextInput {
        id: textInput
        anchors.fill: parent
        anchors.leftMargin: 4 * settings.pixelDensity
        anchors.rightMargin: 4 * settings.pixelDensity
        inputMethodHints: Qt.ImhNoPredictiveText
        activeFocusOnPress: false
        font.family: "Roboto"
        font.pixelSize: 6 * settings.pixelDensity
        verticalAlignment: Text.AlignVCenter
        color: appWindow.colorPalette.label
        clip: true

        MouseArea {
            anchors.fill: parent
            onPressed: mouse => {
                textInput.cursorPosition = textInput.positionAt(mouse.x, mouse.y)

                if (!Qt.inputMethod.visible) {
                    textInput.forceActiveFocus(Qt.MouseFocusReason)
                    Qt.inputMethod.show()
                }
            }
        }
    }
}
