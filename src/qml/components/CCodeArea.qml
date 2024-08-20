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

Item {
    id: cCodeArea

    property alias text: textEdit.text
    property alias selectedText: textEdit.selectedText
    property int indentSize: 0

    readonly property bool useNativeTouchHandling : (Qt.platform.os === "ios")

    onIndentSizeChanged: {
        var indentString = ""
        for (var i = 0; i < indentSize; i++)
            indentString += " "
        textEdit.indentString = indentString
    }

    function paste() {
        textEdit.textChangedManually = true
        textEdit.paste()
    }

    function copy() {
        textEdit.copy()
    }

    function cut() {
        textEdit.textChangedManually = true
        textEdit.cut()
    }

    function selectAll() {
        textEdit.selectAll()
        textEdit.leftSelectionHandle.setPosition()
        textEdit.rightSelectionHandle.setPosition()
    }

    onActiveFocusChanged: {
        if (activeFocus)
            textEdit.forceActiveFocus()
    }

    LineNumbersHelper {
        id: lineNumbersHelper
    }

    Rectangle {
        id: lineNumbers
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: column.width //* 1.2
        color: appWindow.colorPalette.lineNumbersBackground

        Column {
            id: column
            y: 2 * settings.pixelDensity - flickable.contentY
            anchors.horizontalCenter: parent.horizontalCenter

            Repeater {
                id: lineNumberRepeater
                model: lineNumbersHelper.lineCount
                delegate: Text {
                    readonly property bool isCurrentLine :
                        lineNumbersHelper.isCurrentBlock(index, textEdit.cursorPosition);

                    anchors.right: column.right
                    color: isCurrentLine ?
                               appWindow.colorPalette.label :
                               appWindow.colorPalette.lineNumber
                    height: lineNumbersHelper.height(index)
                    font.family: settings.font
                    font.pixelSize: settings.fontSize
                    font.bold: isCurrentLine
                    text: index + 1
                }
            }
        }
    }

    CFlickable {
        id: flickable
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: lineNumbers.right
        anchors.right: (scrollBar.visible) ? scrollBar.left : parent.right
        interactive: useNativeTouchHandling
        flickableDirection: Flickable.VerticalFlick

        function ensureVisible(cursor)
        {
            if (textEdit.currentLine === 1)
                contentY = 0
            else if (textEdit.currentLine === textEdit.lineCount && flickable.visibleArea.heightRatio < 1)
                contentY = contentHeight - height
            else
            {
                if (contentY >= cursor.y)
                    contentY = cursor.y
                else if (contentY + height <= cursor.y + cursor.height)
                    contentY = cursor.y + cursor.height - height
            }
        }

        TextEdit {
            id: textEdit
            anchors.left: parent.left
            anchors.right: parent.right

            color: appWindow.colorPalette.editorNormal
            selectionColor: appWindow.colorPalette.editorSelection
            selectedTextColor: appWindow.colorPalette.editorSelectedText

            font.family: settings.font
            font.pixelSize: settings.fontSize
            textMargin: (1.5 * settings.pixelDensity)
            wrapMode: TextEdit.Wrap
            textFormat: TextEdit.PlainText
            inputMethodHints: Qt.ImhNoPredictiveText
            activeFocusOnPress: useNativeTouchHandling

            property string indentString: ""

            property int currentLine: cursorRectangle.y / cursorRectangle.height + 1

            onContentHeightChanged:
                flickable.contentHeight = contentHeight

            onWidthChanged: {
                lineNumberRepeater.model = 0
                lineNumberRepeater.model = lineNumbersHelper.lineCount
            }

            onTextChanged: {
                lineNumberRepeater.model = 0
                lineNumberRepeater.model = lineNumbersHelper.lineCount
            }

            property bool textChangedManually: false
            property string previousText: ""
            onLengthChanged: {
                if (settings.indentSize === 0)
                    return

                // This is kind of stupid workaround, we forced to do this check because TextEdit sends
                // us "textChanged" and "lengthChanged" signals after every select() and forceActiveFocus() call
                if (text !== previousText)
                {
                    if (textChangedManually)
                    {
                        previousText = text
                        textChangedManually = false
                        return
                    }

                    if (length > previousText.length)
                    {
                        var textBeforeCursor
                        var openBrackets
                        var closeBrackets
                        var openBracketsCount
                        var closeBracketsCount
                        var indentDepth
                        var indentString

                        var lastCharacter = text[cursorPosition - 1]

                        switch (lastCharacter)
                        {
                        case "\n":
                            textBeforeCursor = text.substring(0, cursorPosition - 1)
                            openBrackets = textBeforeCursor.match(/\{/g)
                            closeBrackets = textBeforeCursor.match(/\}/g)

                            if (openBrackets !== null)
                            {
                                openBracketsCount = openBrackets.length
                                closeBracketsCount = 0

                                if (closeBrackets !== null)
                                    closeBracketsCount = closeBrackets.length

                                indentDepth = openBracketsCount - closeBracketsCount
                                indentString = new Array(indentDepth + 1).join(textEdit.indentString)
                                textChangedManually = true
                                insert(cursorPosition, indentString)
                            }
                            break
                        case "}":
                            var lineBreakPosition
                            for (var i = cursorPosition - 2; i >= 0; i--)
                            {
                                if (text[i] !== " ")
                                {
                                    if (text[i] === "\n")
                                        lineBreakPosition = i

                                    break
                                }
                            }

                            if (lineBreakPosition !== undefined)
                            {
                                textChangedManually = true
                                remove(lineBreakPosition + 1, cursorPosition - 1)

                                textBeforeCursor = text.substring(0, cursorPosition - 1)
                                openBrackets = textBeforeCursor.match(/\{/g)
                                closeBrackets = textBeforeCursor.match(/\}/g)

                                if (openBrackets !== null)
                                {
                                    openBracketsCount = openBrackets.length
                                    closeBracketsCount = 0

                                    if (closeBrackets !== null)
                                        closeBracketsCount = closeBrackets.length

                                    indentDepth = openBracketsCount - closeBracketsCount - 1
                                    indentString = new Array(indentDepth + 1).join(textEdit.indentString)
                                    textChangedManually = true
                                    insert(cursorPosition - 1, indentString)
                                }
                            }

                            break
                        }
                    }

                    previousText = text
                }
            }

            SyntaxHighlighter {
                id: syntaxHighlighter

                normalColor: appWindow.colorPalette.editorNormal
                commentColor: appWindow.colorPalette.editorComment
                numberColor: appWindow.colorPalette.editorNumber
                stringColor: appWindow.colorPalette.editorString
                operatorColor: appWindow.colorPalette.editorOperator
                keywordColor: appWindow.colorPalette.editorKeyword
                builtInColor: appWindow.colorPalette.editorBuiltIn
                markerColor: appWindow.colorPalette.editorMarker
                itemColor: appWindow.colorPalette.editorItem
                propertyColor: appWindow.colorPalette.editorProperty
            }

            Component.onCompleted: {
                // oskEventFixer.setupImEventFilter(textEdit)
                lineNumbersHelper.document = textEdit.textDocument
                syntaxHighlighter.setHighlighter(textEdit)
                // if (ProjectManager.project !== "") {
                //     // add custom components
                //     var files = ProjectManager.files()
                //     for (var i = 0; i < files.length; i++) {
                //         var filename = files[i].name.split(".")
                //         if (filename[0] !== "main") {
                //             if (filename[1] === "qml")
                //                 syntaxHighlighter.addQmlComponent(filename[0])
                //             if (filename[1] === "js")
                //                 syntaxHighlighter.addJsComponent(filename[0])
                //         }
                //     }
                //     syntaxHighlighter.rehighlight()
                // }
            }

            MouseArea {
                id: mainMouseArea
                anchors.fill: parent
                enabled: !useNativeTouchHandling
                preventStealing: true

                property int startX
                property int startY
                property int startPosition
                property int endPosition

                onPressed: mouse => {
                    textEdit.contextMenu.visible = false

                    startX = mouse.x
                    startY = mouse.y
                    startPosition = textEdit.positionAt(mouse.x, mouse.y)
                    textEdit.cursorPosition = startPosition
                    textEdit.forceActiveFocus()

                    if (!Qt.inputMethod.visible)
                        Qt.inputMethod.show()

                    mouse.accepted = true
                }

                onPositionChanged: mouse => {
                    if (textEdit.contextMenu.visible)
                    {
                        mouse.accepted = true
                        return
                    }

                    var newPosition = textEdit.positionAt(mouse.x, mouse.y)
                    if (newPosition !== endPosition)
                    {
                        endPosition = newPosition
                        textEdit.select(startPosition, endPosition)
                        if (newPosition > startPosition)
                            flickable.ensureVisible(textEdit.positionToRectangle(textEdit.selectionEnd))
                        else
                            flickable.ensureVisible(textEdit.positionToRectangle(textEdit.selectionStart))
                    }
                    mouse.accepted = true
                }

                onPressAndHold: mouse => {
                    var distance = Math.sqrt(Math.pow(mouse.x - startX, 2) + Math.pow(mouse.y - startY, 2))
                    if (distance < textEdit.cursorRectangle.height)
                    {
                        if (textEdit.selectedText.length === 0 && !platformHasNativeCopyPaste)
                            textEdit.contextMenu.visible = true
                    }
                    mouse.accepted = true
                }

                onWheel: wheel => {
                    const newYPos = flickable.contentY - wheel.angleDelta.y
                    if (newYPos < 0) {
                        return
                    } else if (newYPos + flickable.height >= flickable.contentHeight) {
                        return
                    }

                    flickable.flick(0, 0);
                    flickable.contentY = newYPos
                }
            }

            MultiPointTouchArea {
                id: touchArea
                readonly property int mode_scroll : 0;
                readonly property int mode_position : 1;
                readonly property int mode_select : 2;
                property int mode: mode_scroll
                enabled: !useNativeTouchHandling
                onModeChanged: {
                    const startPosition = textEdit.positionAt(touchPoint.x, touchPoint.y)

                    switch (mode) {
                    case mode_position:
                        mainMouseArea.startX = touchPoint.x
                        mainMouseArea.startY = touchPoint.y
                        textEdit.cursorPosition = startPosition
                        textEdit.forceActiveFocus()

                        if (!Qt.inputMethod.visible)
                            Qt.inputMethod.show()

                        return;

                    case mode_select:
                        textEdit.selectWord()
                        textEdit.leftSelectionHandle.setPosition()
                        textEdit.rightSelectionHandle.setPosition()
                        if (!platformHasNativeCopyPaste) {
                            textEdit.contextMenu.visible = true
                        }
                        return;
                    default:
                        return;
                    }
                }

                anchors.fill: parent
                mouseEnabled: false
                touchPoints: [
                    TouchPoint {
                        id: touchPoint
                        property int actualY : 0
                        property int actualPreviousY : 0
                        property bool firstTouch : true
                        readonly property int moveDelta : (actualY - actualPreviousY)

                        onYChanged: {
                            const newYPos = flickable.contentY - moveDelta

                            if (newYPos < 0) {
                                return
                            } else if (newYPos + flickable.height >= flickable.contentHeight) {
                                return
                            }

                            if (touchArea.touchIsInWiggleRoom())
                                return

                            flickable.contentY = newYPos
                        }
                    }
                ]

                function touchIsInWiggleRoom() {
                    return (Math.abs(touchPoint.moveDelta) < 3) && !touchPoint.firstTouch
                }

                Timer {
                    id: selectionDetectTimer
                    repeat: false
                    interval: 500
                    onTriggered: {
                        touchArea.mode = touchArea.mode_position
                        touchArea.mode = touchArea.mode_select
                    }
                }

                onPressed: {
                    touchPoint.firstTouch = false
                    touchPoint.actualY = touchPoint.y
                    touchPoint.actualPreviousY = touchPoint.previousY
                    selectionDetectTimer.start()
                }

                onUpdated: {
                    touchPoint.actualY = touchPoint.y
                    touchPoint.actualPreviousY = touchPoint.previousY
                    if (touchIsInWiggleRoom())
                        return

                    touchPoint.firstTouch = true
                    selectionDetectTimer.stop()
                }

                onReleased: {
                    touchPoint.actualY = 0
                    touchPoint.actualPreviousY = 0

                    const positionWasRunning = selectionDetectTimer.running
                    selectionDetectTimer.stop()

                    if (positionWasRunning) {
                        touchArea.mode = touchArea.mode_position
                    }
                    touchArea.mode = touchArea.mode_scroll
                }
            }

            property Item leftSelectionHandle: Item {
                width: platformHasNativeDragHandles ? 0 : textEdit.cursorRectangle.height
                height: width
                parent: textEdit
                visible: textEdit.selectedText !== ""
                onXChanged:
                    if (leftSelectionMouseArea.pressed)
                        select()
                onYChanged:
                    if (leftSelectionMouseArea.pressed)
                        select()

                function select() {
                    var currentPosition = textEdit.positionAt(x + width / 2, y + height)
                    if (currentPosition < textEdit.selectionEnd)
                    {
                        textEdit.select(currentPosition, textEdit.selectionEnd)
                        flickable.ensureVisible(textEdit.positionToRectangle(textEdit.selectionStart))
                    }
                }

                function setPosition() {
                    var positionRectangle = textEdit.positionToRectangle(textEdit.selectionStart)
                    textEdit.leftSelectionHandle.x = positionRectangle.x - textEdit.leftSelectionHandle.width / 2
                    textEdit.leftSelectionHandle.y = positionRectangle.y - textEdit.leftSelectionHandle.height
                }

                MouseArea {
                    id: leftSelectionMouseArea
                    anchors.fill: parent
                    anchors.margins: -parent.width / 1.5
                    drag.target: textEdit.leftSelectionHandle
                    drag.smoothed: false
                    onReleased:
                        textEdit.leftSelectionHandle.setPosition()
                }

                Connections {
                    target: (leftSelectionMouseArea.pressed) ? null : textEdit
                    // onCursorPositionChanged:
                    //     textEdit.leftSelectionHandle.setPosition()
                    function onCursorPositionChanged() {
                        textEdit.leftSelectionHandle.setPosition()
                    }
                }

                Rectangle {
                    anchors.horizontalCenter: parent.left
                    width: parent.width
                    height: parent.height
                    radius: width / 2
                    color: appWindow.colorPalette.editorSelectionHandle

                    Rectangle {
                        width: Math.floor(parent.width / 2)
                        height: width
                        color: parent.color
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                    }
                }
            }

            property Item rightSelectionHandle: Item {
                width: platformHasNativeDragHandles ? 0 : textEdit.cursorRectangle.height
                height: width
                parent: textEdit
                visible: textEdit.selectedText !== ""
                onXChanged:
                    if (rightSelectionMouseArea.pressed)
                        select()
                onYChanged:
                    if (rightSelectionMouseArea.pressed)
                        select()

                function select() {
                    var currentPosition = textEdit.positionAt(x + width / 2, y)
                    if (currentPosition > textEdit.selectionStart)
                    {
                        textEdit.select(textEdit.selectionStart, currentPosition)
                        flickable.ensureVisible(textEdit.positionToRectangle(textEdit.selectionEnd))
                    }
                }

                function setPosition() {
                    var positionRectangle = textEdit.positionToRectangle(textEdit.selectionEnd)
                    textEdit.rightSelectionHandle.x = positionRectangle.x - textEdit.rightSelectionHandle.width / 2
                    textEdit.rightSelectionHandle.y = positionRectangle.y + positionRectangle.height
                }

                MouseArea {
                    id: rightSelectionMouseArea
                    anchors.fill: parent
                    anchors.margins: -parent.width / 1.5
                    drag.target: textEdit.rightSelectionHandle
                    drag.smoothed: false
                    onReleased:
                        textEdit.rightSelectionHandle.setPosition()
                }

                Connections {
                    target: (rightSelectionMouseArea.pressed) ? null : textEdit
                    // onCursorPositionChanged:
                    //     textEdit.rightSelectionHandle.setPosition()
                    function onCursorPositionChanged() {
                        textEdit.rightSelectionHandle.setPosition()
                    }
                }

                Rectangle {
                    anchors.horizontalCenter: parent.right
                    width: parent.width
                    height: parent.height
                    radius: width / 2
                    color: appWindow.colorPalette.editorSelectionHandle

                    Rectangle {
                        width: Math.floor(parent.width / 2)
                        height: width
                        color: parent.color
                        anchors.top: parent.top
                        anchors.left: parent.left
                    }
                }
            }

            onCursorPositionChanged:
                textEdit.contextMenu.visible = false

            property Item contextMenu: ListView {
                parent: textEdit
                visible: false

                property int margin: 3
                property int delegateWidth: 40 * settings.pixelDensity
                property int delegateHeight: 12 * settings.pixelDensity

                width: delegateWidth
                height: delegateHeight * count
                boundsBehavior: Flickable.StopAtBounds

                model: ListModel {
                    ListElement { text: qsTr("Undo") }
                    ListElement { text: qsTr("Redo") }
                    ListElement { text: qsTr("Paste") }
                }

                function contextMenuCallback(index) {
                    visible = false
                    switch (index)
                    {
                    case 0:
                        textEdit.undo()
                        break
                    case 1:
                        textEdit.redo()
                        break
                    case 2:
                        cCodeArea.paste()
                        break
                    }
                }

                delegate: CContextMenuButton {
                    width: ListView.view.delegateWidth
                    height: ListView.view.delegateHeight
                    text: model.text
                    onClicked: ListView.view.contextMenuCallback(index)
                }

                onVisibleChanged: {
                    if (visible)
                    {
                        var positionRectangle = textEdit.positionToRectangle(textEdit.cursorPosition)

                        if (isEnoughSpaceAtLeft() && !isEnoughSpaceAtRight())
                            x = textEdit.width - width - margin
                        else if (!isEnoughSpaceAtLeft() && isEnoughSpaceAtRight())
                            x = margin
                        else
                            x = positionRectangle.x - width / 2

                        if (isEnoughSpaceAtTop())
                            y = positionRectangle.y - margin - height
                        else if (isEnoughSpaceAtBottom())
                            y = positionRectangle.y + positionRectangle.height + margin
                        else
                            y = positionRectangle.y + positionRectangle.height / 2 - height / 2
                    }
                }

                function isEnoughSpaceAtTop() {
                    var positionRectangle = textEdit.positionToRectangle(textEdit.cursorPosition)
                    return (positionRectangle.y  - height - margin > flickable.contentY)
                }

                function isEnoughSpaceAtBottom() {
                    var positionRectangle = textEdit.positionToRectangle(textEdit.cursorPosition)
                    return (positionRectangle.y  + positionRectangle.height + height + margin < flickable.contentY + flickable.height)
                }

                function isEnoughSpaceAtLeft() {
                    var positionRectangle = textEdit.positionToRectangle(textEdit.cursorPosition)
                    return (positionRectangle.x - width / 2 > 0)
                }

                function isEnoughSpaceAtRight() {
                    var positionRectangle = textEdit.positionToRectangle(textEdit.cursorPosition)
                    return (positionRectangle.x + width / 2 < textEdit.width)
                }
            }
        }
    }

    CNavigationScrollBar {
        id: scrollBar

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right

        flickableItem: flickable
    }
}
