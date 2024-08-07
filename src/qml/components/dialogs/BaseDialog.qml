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
    id: baseDialog
    anchors.fill: parent
    visible: false

    property int popupWidth: width * 0.82
    property int popupHeight: height * 0.7

    property var contentItem : undefined;

    property string title

    function initialize(parameters) {}

    signal process(var value)
    signal close()

    onVisibleChanged: {
        showAnimation.start()
    }

    ParallelAnimation {
        id: showAnimation

        NumberAnimation {
            target: baseDialog
            property: "opacity"
            duration: 150
            easing.type: Easing.Linear
            from: 0.0
            to: 1.0
        }

        NumberAnimation {
            target: contentItem
            property: "scale"
            duration: 150
            easing.type: Easing.Linear
            from: 0.9
            to: 1.0
        }
    }

    Rectangle {
        anchors.fill: parent
        color: appWindow.colorPalette.dialogOverlay
    }
}
