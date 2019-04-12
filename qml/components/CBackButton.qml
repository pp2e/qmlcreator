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
import QtQuick.Layouts 1.2

Item {
    id: cBackButton

    property alias text: buttonLabel.text
    property bool enableBack : true
    property var targetSplit : null
    signal clicked()

    Rectangle {
        id: background
        anchors.fill: parent
        color: palette.button
        visible: mouseArea.pressed
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 5 * settings.pixelDensity
        anchors.rightMargin: 5 * settings.pixelDensity
        spacing: 3 * settings.pixelDensity

        CIcon {
            text: enableBack ? "\uf104" : ""
        }

        CLabel {
            id: buttonLabel
            Layout.fillWidth: true
            Layout.fillHeight: true
            font.pixelSize: 10 * settings.pixelDensity
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: enableBack
        onClicked: {
            if (!enableBack)
                return;

            cBackButton.clicked()

            if (targetSplit !== undefined &&
                    targetSplit !== null) {
                targetSplit.pop()
                return;
            }

            if (!splitView.leftView.busy && !splitView.rightView.busy)
                splitView.popPage()
        }
    }
}
