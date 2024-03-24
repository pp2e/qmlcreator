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

Loader {
    id: dialogLoader

    visible: status === Loader.Loading || status === Loader.Ready

    property var parameters
    property var callback

    property alias types: dialogTypes

    QtObject {
        id: dialogTypes

        property string message: "components/dialogs/MessageDialog.qml"
        property string confirmation: "components/dialogs/ConfirmationDialog.qml"
        property string list: "components/dialogs/ListDialog.qml"
        property string fontFamily: "components/dialogs/FontFamilyDialog.qml"
        property string fontSize: "components/dialogs/FontSizeDialog.qml"
        property string indentSize: "components/dialogs/IndentSizeDialog.qml"
        property string newFile: "components/dialogs/NewFileDialog.qml"
        property string newDir: "components/dialogs/NewDirDialog.qml"
        property string newProject: "components/dialogs/NewProjectDialog.qml"
    }

    function open(type, parameters, callback) {
        dialogLoader.parameters = parameters
        dialogLoader.callback = callback
        dialogLoader.source = type
    }

    function close() {
        source = ""
    }

    onLoaded: {
        item.initialize(parameters)
        item.visible = true
    }

    Connections {
        target: item

        function onProcess(value) {
            dialogLoader.source = ""
            dialogLoader.callback(value)
        }

        function onClose() {
            dialogLoader.source = ""
        }
    }
}
