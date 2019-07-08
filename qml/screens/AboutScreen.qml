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
import "../components"

BlankScreen {
    id: aboutScreen

    property var backPressed : function () {}

    CToolBar {
        id: toolBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        CBackButton {
            anchors.fill: parent
            text: qsTr("About")
            enableBack: !enableDualView
            onClicked: backPressed()
        }
    }

    CTextArea {
        anchors.top: toolBar.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        text:  textStyle() +
               "QML Creator " + Qt.application.version + "<br>
               Based on Qt Quick (Qt " + qtVersion + ")<br>
               Built on " + buildDateTime + "<br><br>
               Copyright (C) 2019 <a href=\"https://fredl.me/\">Alfred Neumayer</a><br>
               <a class=\"link\" href=\"mailto:dev.beidl@gmail.com\">dev.beidl@gmail.com</a><br><br>
               Copyright (C) 2013-2015 <a href=\"https://linkedin.com/in/olegyadrov/\">Oleg Yadrov</a><br>
               <a class=\"link\" href=\"mailto:wearyinside@gmail.com\">wearyinside@gmail.com</a><br><br>

               QML Creator application is distributed under
               <a href=\"http://www.apache.org/licenses/LICENSE-2.0\">Apache Software License, Version 2</a>.<br><br>

               You are welcome to support Alfred Neumayer by donating via
               <a href=\"https://paypal.me/beidl\">PayPal</a><br><br>

               You are welcome to support Oleg Yadrov by donating some bitcoins to
               <a href=\"https://blockchain.info/address/1weary24fY4PqH542yGEgwZcYksGv7zLB\">1weary24fY4PqH542yGEgwZcYksGv7zLB</a><br><br>

               Unless required by applicable law or agreed to in writing, software distributed under the License
               is distributed on an \"AS IS\" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.<br><br>

               Qt is a registered trademark of The Qt Company Ltd. and/or its subsidiaries."
    }
}
