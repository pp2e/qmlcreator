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
    id: cSettingButton

    anchors.left: parent.left
    anchors.right: parent.right
    implicitHeight: 20 * settings.pixelDensity

    property alias text: buttonLabel.text
    property alias description: descriptionLabel.text

    signal clicked()

    CHorizontalSeparator {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
    }

    Rectangle {
        anchors.fill: parent
        color: appWindow.colorPalette.button
        visible: mouseArea.pressed
    }

    Column {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 5 * settings.pixelDensity
        anchors.rightMargin: 5 * settings.pixelDensity
        spacing: 0.5 * settings.pixelDensity

        CLabel {
            id: buttonLabel
            anchors.left: parent.left
            anchors.right: parent.right
        }

        CLabel {
            id: descriptionLabel
            anchors.left: parent.left
            anchors.right: parent.right
            font.pixelSize: 5 * settings.pixelDensity
            color: appWindow.colorPalette.description
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: cSettingButton.clicked()
    }
}
