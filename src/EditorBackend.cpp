#include "EditorBackend.h"

#include <QTextBlock>
#include <QAbstractTextDocumentLayout>

#include "tree_sitter/api.h"

#include "modulesfinder.h"
extern "C" {
// Declare the `tree_sitter_json` function, which is
// implemented by the `tree-sitter-json` library.
const TSLanguage *tree_sitter_qmljs(void);
}

EditorBackend::EditorBackend(QObject *parent)
    : QObject{parent}
{}

EditorBackend::~EditorBackend() {
    if (m_parser) {
        ts_parser_delete(m_parser);
        ts_tree_delete(m_tree);
    }
}

const QTextCharFormat textFormat(QBrush background, bool underline = false) {
    QTextCharFormat format;
    format.setForeground(background);
    format.setFontUnderline(underline);
    return format;
}

TSPoint tsPointFromPos(QList<int> lengths, int pos) {
    TSPoint point = {0, 0};
    if (lengths.length() == 0)
        // we cannot count if have no info
        return point;

    while (pos >= lengths[point.row]) {
        // qDebug() << point.row << lengths.length() << pos;
        pos -= lengths[point.row];
        if (point.row == lengths.length()-1) {
            pos = lengths.last();
            break;
        }
        point.row++;
    }
    point.column = pos;
    return point;
}

bool TsTreeCursorGotoPos(TSTreeCursor *cursor, TSPoint pos) {
    if (!ts_tree_cursor_goto_first_child(cursor)) return false;

    do {
        TSNode node = ts_tree_cursor_current_node(cursor);
        TSPoint start = ts_node_start_point(node);
        TSPoint end = ts_node_end_point(node);
        if ((pos.row > start.row || (pos.row == start.row && pos.column > start.column))
            && (pos.row < end.row || (pos.row == end.row && pos.column < end.column)))
            return true;

    } while (ts_tree_cursor_goto_next_sibling(cursor));

    return false;
}

void EditorBackend::textChanged(int from, int charsRemoved, int charsAdded) {
    QByteArray data = m_document->toPlainText().toLatin1(); // Latin1 counts russian text as one symbol like QString itself
    std::string source_code = data.constData();

    if (!m_parser) {
        m_parser = ts_parser_new();

        // Set the parser's language (JSON in this case).
        ts_parser_set_language(m_parser, tree_sitter_qmljs());

        m_tree = ts_parser_parse_string(
            m_parser,
            NULL,
            source_code.data(),
            source_code.size()
        );
    } else {
        QList<int> blockLengths;
        for (QTextBlock block = m_document->begin(); block.isValid(); block = block.next()) {
            blockLengths.append(block.length());
        }
        blockLengths.last()--;

        TSPoint startPoint = tsPointFromPos(blockLengths, from);
        TSPoint newEndPoint = tsPointFromPos(blockLengths, from+charsAdded);
        TSPoint oldEndPoint = tsPointFromPos(m_prevBlockLengths, from+charsRemoved);
        m_prevBlockLengths = blockLengths;

        TSInputEdit edit = {
            static_cast<uint32_t>(from), // start_byte;
            static_cast<uint32_t>(from+charsRemoved), // old_end_byte;
            static_cast<uint32_t>(from+charsAdded), // new_end_byte;
            startPoint, // start_point;
            oldEndPoint, // old_end_point;
            newEndPoint, // new_end_point;
        };
        ts_tree_edit(m_tree, &edit);
        m_tree = ts_parser_parse_string(
            m_parser,
            m_tree,
            source_code.data(),
            source_code.size()
        );
    }

    TSNode root_node = ts_tree_root_node(m_tree);

    updateImports();

    if (m_textEdit->cursorPosition() > 0) {
        TSTreeCursor cursor = ts_tree_cursor_new(root_node);
        TSPoint point = tsPointFromPos(m_prevBlockLengths, m_textEdit->cursorPosition());

        int tabs = 0;
        TSNode node = ts_tree_cursor_current_node(&cursor);
        TSPoint start = ts_node_start_point(node);
        TSPoint end = ts_node_end_point(node);

        QString node_type = ts_node_type(node);

        while (TsTreeCursorGotoPos(&cursor, point)) {
            node = ts_tree_cursor_current_node(&cursor);
            start = ts_node_start_point(node);
            end = ts_node_end_point(node);

            node_type = ts_node_type(node);
        }

        QStringList suggests;
        if (node_type == "ui_object_initializer") {
            QTextCursor textCursor(m_document);
            textCursor.setPosition(m_textEdit->cursorPosition());
            QString line = textCursor.block().text().first(textCursor.positionInBlock());

            int firstSpace = line.lastIndexOf(" ");
            if (firstSpace > 0)
                line = line.mid(firstSpace+1);

            for (QStringList &import : m_importedTypes.values()) {
                for (QString &component : import) {
                    if (component.size() > line.size() && component.startsWith(line))
                        suggests << component;
                }
            }
        }

        if (suggests.size() > 4)
            suggests = suggests.first(4);

        if (m_suggestions != suggests) {
            m_suggestions = suggests;
            emit suggestionsChanged();
        }
    }

    TSTreeCursor cursor = ts_tree_cursor_new(root_node);
    for (QTextBlock block = m_document->begin(); block.isValid(); block = block.next()) {
        block.layout()->clearFormats();

        highlightBlock(cursor, block);
    }
}

void EditorBackend::highlightText(QTextBlock block, int start, int end, QTextCharFormat format) {
    QTextLayout *layout = block.layout();
    QList<QTextLayout::FormatRange> ranges = layout->formats();
    QTextLayout::FormatRange r {
        start,
        end-start,
        format
    };
    ranges.append(r);
    layout->setFormats(ranges);
}

bool TsTreeCursorGotoNextNode(TSTreeCursor *cursor) {
    // if (ts_tree_cursor_goto_first_child(cursor)) return true;
    while (!ts_tree_cursor_goto_next_sibling(cursor)) {
        if (!ts_tree_cursor_goto_parent(cursor)) return false;
    }
    return true;
}

void EditorBackend::highlightBlock(TSTreeCursor &cursor, QTextBlock block) {
    while (ts_node_start_point(ts_tree_cursor_current_node(&cursor)).row <= block.blockNumber()
           && ts_node_end_point(ts_tree_cursor_current_node(&cursor)).row >= block.blockNumber()) {
        TSNode node = ts_tree_cursor_current_node(&cursor);
        int start = ts_node_start_point(node).row < block.blockNumber() ? 0 : ts_node_start_point(node).column;
        int end = ts_node_end_point(node).row > block.blockNumber() ? block.length()-1 /*1 for enter*/ : ts_node_end_point(node).column;

        if (start == end) return;

        QString node_type = ts_node_type(node);
        QChar firstChar = block.text().at(start);

        if (node_type == "comment") {
            // editorComment
            highlightText(block, start, end, textFormat(m_commentColor));
        } else if (node_type == "number") {
            // editorNumber
            highlightText(block, start, end, textFormat(m_numberColor));
        } else if (node_type == "string") {
            // editorString
            highlightText(block, start, end, textFormat(m_stringColor));
        } else if (!ts_node_is_named(node) && firstChar.isLetter() || node_type == "type_identifier") {
            // editorKeyword
            highlightText(block, start, end, textFormat(m_keywordColor));
        } else if (node_type == "identifier" || node_type == "property_identifier") {
            if (firstChar.isLower()) // Starts with lower
                // editorProperty
                highlightText(block, start, end, textFormat(m_propertyColor));
            else
                // editorItem
                highlightText(block, start, end, textFormat(m_itemColor));
        } else if (node_type == "ERROR") {
            // editorError
            highlightText(block, start, end, textFormat(m_errorColor, true));
        } else {
            // If node was recognized try inner node
            if (ts_tree_cursor_goto_first_child(&cursor))
                // If succeed try again
                // Possible bug here: code assumes that first child will start in same line
                continue;
        }

        // Do not go to next node if if it exists on next line
        if (ts_node_end_point(node).row > block.blockNumber()) break;

        // If node end is on this line we request next node
        if (!TsTreeCursorGotoNextNode(&cursor)) return;
    }
}

void EditorBackend::setTextEdit(QQuickTextEdit *textEdit) {
    if (m_textEdit == textEdit)
        return;

    if (m_textEdit)
        m_textEdit->removeEventFilter(this);

    if (m_document)
        disconnect(m_document, &QTextDocument::contentsChange,
                   this, &EditorBackend::textChanged);

    m_textEdit = textEdit;
    m_textEdit->installEventFilter(this);

    m_document = m_textEdit->textDocument()->textDocument();
    connect(m_document, &QTextDocument::contentsChange,
            this, &EditorBackend::textChanged);
}

bool EditorBackend::eventFilter(QObject *object, QEvent *event) {
    if (object != m_textEdit)
        return false;

    if (event->type() != QEvent::KeyPress)
        return false;

    QKeyEvent *key = static_cast<QKeyEvent*>(event);

    // sorry for trash code
    if (key->key() != Qt::Key_Tab && key->key() != Qt::Key_Return && key->key() != Qt::Key_Enter && key->text() != "{" && key->text() != "[" && key->text() != "}")
        return false;

    TSNode root_node = ts_tree_root_node(m_tree);
    TSTreeCursor cursor = ts_tree_cursor_new(root_node);
    TSPoint point = tsPointFromPos(m_prevBlockLengths, m_textEdit->cursorPosition());

    int tabs = 0;
    TSNode node = ts_tree_cursor_current_node(&cursor);
    TSPoint start = ts_node_start_point(node);
    TSPoint end = ts_node_end_point(node);

    while (TsTreeCursorGotoPos(&cursor, point)) {
        node = ts_tree_cursor_current_node(&cursor);
        start = ts_node_start_point(node);
        end = ts_node_end_point(node);

        QString node_type = ts_node_type(node);
        if (node_type == "ui_object_initializer" || node_type == "array"  || node_type == "ui_object_array")
            tabs++;
    }
    
    if (key->key() == Qt::Key_Tab) {
        TSTreeCursor cursor2 = ts_tree_cursor_new(root_node);
        while (TsTreeCursorGotoPos(&cursor2, point)) {
            node = ts_tree_cursor_current_node(&cursor2);

            qDebug() << ts_node_type(node);
        }
        qDebug() << "tab level" << tabs;
        return true;
    }

    if (key->key() == Qt::Key_Tab) {
        QTextCursor cursor(m_document);
        cursor.setPosition(m_textEdit->cursorPosition());

        QString text = cursor.block().text().first(cursor.positionInBlock());
        bool onlySpaces = true;
        for (QChar ch : text) {
            if (ch != ' ') {
                onlySpaces = false;
                break;
            }
        }

        if (onlySpaces) {
            cursor.insertText(QString(" ").repeated(4-text.length()%4));
            return true;
        }
    }

    if (key->key() == Qt::Key_Return || key->key() == Qt::Key_Enter) {
        if (point.row == end.row && point.column+1 == end.column) {
            QTextCursor cursor(m_document);
            cursor.setPosition(m_textEdit->cursorPosition());
            cursor.insertText("\n" + QString("    ").repeated(tabs) + "\n" + QString("    ").repeated(tabs-1));
            m_textEdit->setCursorPosition(m_textEdit->cursorPosition()-1-4*(tabs-1));
        } else {
            QTextCursor cursor(m_document);
            cursor.setPosition(m_textEdit->cursorPosition());
            cursor.insertText("\n" + QString("    ").repeated(tabs));
        }
        return true;
    }

    if (key->text() == "{") {
        QTextCursor cursor(m_document);
        cursor.setPosition(m_textEdit->cursorPosition());
        cursor.insertText("{\n" + QString("    ").repeated(tabs+1) + "\n" + QString("    ").repeated(tabs) + "}");
        m_textEdit->setCursorPosition(m_textEdit->cursorPosition()-1-4*tabs-1);
        return true;
    }
    
    if (key->text() == "[") {
        QTextCursor cursor(m_document);
        cursor.setPosition(m_textEdit->cursorPosition());
        cursor.insertText("[\n" + QString("    ").repeated(tabs+1) + "\n" + QString("    ").repeated(tabs) + "]");
        m_textEdit->setCursorPosition(m_textEdit->cursorPosition()-1-4*tabs-1);
        return true;
    }

    if (key->text() == "}") {
        QTextCursor cursor(m_document);
        cursor.setPosition(m_textEdit->cursorPosition());
        if (cursor.atBlockEnd()) {
            QString text = cursor.block().text();
            bool onlySpaces = true;
            for (QChar ch : text) {
                if (ch != ' ') {
                    onlySpaces = false;
                    break;
                }
            }
            if (onlySpaces) {
                cursor.select(QTextCursor::SelectionType::BlockUnderCursor);
                cursor.insertText("\n" + QString("    ").repeated(tabs-1) + "}");
                return true;
            }
        }
    }

    return false;
}

void addImport(QMap<QString, QString> &imports, QString name) {
    if (imports.contains(name))
        return;

    if (name == "QML") {
        imports.insert("QML", "QML");
        return;
    }

    QString path = ModulesFinder::getModulePath(name);
    if (!path.isEmpty())
        imports.insert(name, path);

    for (QString &dep : ModulesFinder::getModuleDependencies(path))
        addImport(imports, dep);
}

void EditorBackend::updateImports() {
    QByteArray data = m_document->toPlainText().toLatin1(); // Latin1 counts russian text as one symbol like QString itself
    std::string source_code = data.constData();
    TSNode root_node = ts_tree_root_node(m_tree);
    QMap<QString, QString> imports;
    // Walk through imports
    // TODO: probably create only one walkthrough loop from this and rehighlight code
    TSTreeCursor importsCursor = ts_tree_cursor_new(root_node);
    ts_tree_cursor_goto_first_child(&importsCursor);
    while (strcmp(ts_node_type(ts_tree_cursor_current_node(&importsCursor)), "ui_object_definition")!=0) {
        if (strcmp(ts_node_type(ts_tree_cursor_current_node(&importsCursor)), "ui_import")==0) {
            TSNode import = ts_node_child_by_field_name(ts_tree_cursor_current_node(&importsCursor), "source", 6);
            uint32_t start = ts_node_start_byte(import);
            uint32_t end = ts_node_end_byte(import);

            addImport(imports, source_code.substr(start, end-start).data());
        }
        if (!ts_tree_cursor_goto_next_sibling(&importsCursor))
            return;
    }
    // sorry another trash code
    for (const QString import : m_importedTypes.keys()) {
        if (!imports.contains(import)) {
            qDebug() << "remove component" << import << m_importedTypes.value(import) << "components";
            m_importedTypes.remove(import);
        }
    }
    for (const QString import : imports.keys()) {
        if (!m_importedTypes.contains(import)) {
            m_importedTypes.insert(import, ModulesFinder::getModuleComponents(imports.value(import)));
            qDebug() << "add component" << import << m_importedTypes.value(import) << "components";
        }
    }
}

QStringList EditorBackend::suggestions() {
    return m_suggestions;
}

void EditorBackend::commitSuggestion(QString suggestion) {
    TSNode root_node = ts_tree_root_node(m_tree);
    TSTreeCursor cursor = ts_tree_cursor_new(root_node);
    TSPoint point = tsPointFromPos(m_prevBlockLengths, m_textEdit->cursorPosition());

    int tabs = 0;
    TSNode node = ts_tree_cursor_current_node(&cursor);
    TSPoint start = ts_node_start_point(node);
    TSPoint end = ts_node_end_point(node);

    while (TsTreeCursorGotoPos(&cursor, point)) {
        node = ts_tree_cursor_current_node(&cursor);
        start = ts_node_start_point(node);
        end = ts_node_end_point(node);

        QString node_type = ts_node_type(node);
        if (node_type == "ui_object_initializer" || node_type == "array"  || node_type == "ui_object_array")
            tabs++;
    }

    QTextCursor textCursor(m_document);
    textCursor.setPosition(m_textEdit->cursorPosition());

    textCursor.select(QTextCursor::SelectionType::WordUnderCursor);
    textCursor.insertText(suggestion + " {\n" + QString("    ").repeated(tabs+1) + "\n" + QString("    ").repeated(tabs) + "}");
    m_textEdit->setCursorPosition(m_textEdit->cursorPosition()-1-4*tabs-1);
}
