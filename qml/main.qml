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
import QtQuick.Controls 2.3
import QtQuick.Controls 1.4
import "components"
import "components/dialogs"
import "screens"

CApplicationWindow {
    id: appWindow

    function popPage()  {
        if (rightView.currentItem !== rightView.initialItem) {
            rightView.pop()
            return true;
        }

        if (leftView.currentItem !== leftView.initialItem) {
            leftView.pop()
            return true;
        }

        return false
    }

    onBackPressed: {
        if (dialog.visible)
        {
            dialog.close()
        }
        else
        {
            if (leftView.depth > 1 || rightView.depth > 1)
                popPage()
            else
                Qt.quit()
        }
    }

    SwipeView {
        anchors.fill: parent
        states: [
            State {
                when: !enableDualView
                name: "singleView"
                ParentChange {
                    target: leftView
                    parent: leftStackContainer
                }
                ParentChange {
                    target: rightView
                    parent: leftStackContainer
                }
            },
            State {
                when: enableDualView
                name: "dualView"
                ParentChange {
                    target: leftView
                    parent: leftStackContainer
                }
                ParentChange {
                    target: rightView
                    parent: rightStackContainer
                }
            }
        ]

        // Stack views
        Item {
            StackView {
                id: leftView
                anchors.fill: parent
                enabled: !dialog.visible
                initialItem: MainMenuScreen { }
            }
        }
        Item {
            StackView {
                id: rightView
                anchors.fill: parent
                enabled: !dialog.visible
                initialItem: Item {
                    Image {
                        visible: enableDualView
                        anchors.fill: parent
                        anchors.margins: parent.width / 4
                        fillMode: Image.PreserveAspectFit
                        source: "qrc:/resources/images/icon512.png"
                    }
                }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "white"
        Row {
            anchors.fill: parent

            // Stack view containers
            Rectangle {
                id: leftStackContainer
                clip: true
                width: enableDualView ? parent.width / 3
                                      : parent.width
                height: parent.height
            }
            Rectangle {
                id: rightStackContainer
                clip: true
                width: enableDualView ? (parent.width / 3) * 2
                                      : parent.width
                height: parent.height
            }
        }
    }

    DialogLoader {
        id: dialog
        anchors.fill: parent
    }

    CTooltip {
        id: tooltip
    }
}
