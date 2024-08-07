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

Rectangle {
    id: cToolBar
    height: 22 * settings.pixelDensity + appWindow.insets.top
    width: parent.width
    color: appWindow.colorPalette.toolBarBackground
    default property alias data: childHolder.data
    
    Item {
        id: childHolder
        anchors.fill: parent
        anchors.topMargin: appWindow.insets.top
    }
}
