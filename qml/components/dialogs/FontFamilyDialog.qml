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
import QtQuick.Effects
import ".."

BaseDialog {
    id: fontFamilyDialog
    contentItem: mainContent

    property alias title: titleLabel.text
    property alias model: fontsList.model
    property alias currentIndex: fontsList.currentIndex

    function initialize(parameters) {
        for (var attr in parameters) {
            if (attr === "currentIndex")
                continue;

            fontFamilyDialog[attr] = parameters[attr];
        }

        fontsList.currentIndex = parameters.currentIndex;
        fontsList.positionViewAtIndex(currentIndex, ListView.Contain)
    }

    MultiEffect {
        anchors.fill: mainContent
        shadowEnabled: true
        shadowColor: appWindow.colorPalette.dialogShadow
        shadowBlur: 1
        blurMax: 30 * settings.pixelDensity
        source: mainContent
    }

    Rectangle {
        id: mainContent
        width: popupWidth
        height: popupHeight
        anchors.centerIn: parent
        color: appWindow.colorPalette.dialogBackground

        Rectangle {
            id: header

            height: 22 * settings.pixelDensity
            anchors.left: parent.left
            anchors.right: parent.right
            color: appWindow.colorPalette.toolBarBackground

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                height: Math.max(1, Math.round(0.8 * settings.pixelDensity))
                color: appWindow.colorPalette.toolBarStripe
            }

            CLabel {
                id: titleLabel
                anchors.fill: parent
                anchors.leftMargin: 5 * settings.pixelDensity
                font.pixelSize: 10 * settings.pixelDensity
            }
        }

        ListView {
            id: fontsList

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: header.bottom
            anchors.bottom: parent.bottom
            boundsBehavior: Flickable.StopAtBounds
            clip: true
            delegate: CCheckBox {
                text: model.name
                checked: index === fontsList.currentIndex
                onClicked: fontFamilyDialog.process(index)
                label.font.family: model.name
            }
        }

        CScrollBar {
            flickableItem: fontsList
        }
    }
}
