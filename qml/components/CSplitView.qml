import QtQuick 2.5
import QtQuick.Controls 2.2

Item {
    property alias leftView : leftView
    property alias rightView : rightView

    property alias initialLeftItem : leftView.initialItem
    property alias initialRightItem : rightView.initialItem

    readonly property bool enableDualView : width > height

    function popPage()  {
        if (rightView.depth > 1) {
            rightView.pop()
            return true;
        }

        if (leftView.depth > 1) {
            leftView.pop()
            return true;
        }

        return false
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
                initialItem: null
            }
        }
        Item {
            StackView {
                id: rightView
                anchors.fill: parent
                enabled: !dialog.visible
                initialItem: null
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
}
