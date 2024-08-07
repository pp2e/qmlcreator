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
import QtQml

Rectangle {
     id: cScrollBar

     property Item flickableItem

     anchors.top: flickableItem.top
     anchors.right: flickableItem.right
     anchors.topMargin: flickableItem.visibleArea.yPosition * flickableItem.height
     height: flickableItem.visibleArea.heightRatio * flickableItem.height

     visible: flickableItem.visibleArea.heightRatio < 1
     opacity: 0

     width: 3 * settings.pixelDensity
     color: appWindow.colorPalette.scrollBar

     Behavior on opacity {
         NumberAnimation {
             duration: 300
         }
     }

     Connections {
         target: flickableItem

         function onMovementStarted() {
             cScrollBar.opacity = 1
         }

         function onMovementEnded() {
             cScrollBar.opacity = 0
         }
     }
 }
