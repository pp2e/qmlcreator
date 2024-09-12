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
import QmlCreator
import "../components"

import org.kde.kirigami as Kirigami

Kirigami.Page {
    id: modulesScreen
    padding: 0

    title: qsTr("Modules")

    ModulesFinder {
        id: finder
    }

    ListView {
        id: listView
        anchors.fill: parent

        model: finder.modules

        delegate: CInformationItem {
            width: listView.width
            text: modelData
            description: qsTr("Available")
        }
    }

    CScrollBar {
        flickableItem: listView
    }
}
