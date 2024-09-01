#include "EditorBackend.h"

#include <QTextBlock>
#include <QAbstractTextDocumentLayout>

#include "tree_sitter/api.h"
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

void EditorBackend::setQuickDocument(QQuickTextDocument *quickDocument) {
    m_quickDocument = quickDocument;
    m_document = quickDocument->textDocument();
    connect(m_document, &QTextDocument::contentsChange,
            this, &EditorBackend::textChanged);
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

void EditorBackend::textChanged(int from, int charsRemoved, int charsAdded) {
    QByteArray data = m_document->toPlainText().toLatin1(); // Latin1 counts russian text as one symbol like QString itself
    const char *source_code = data.constData();

    if (!m_parser) {
        m_parser = ts_parser_new();

        // Set the parser's language (JSON in this case).
        ts_parser_set_language(m_parser, tree_sitter_qmljs());

        m_tree = ts_parser_parse_string(
            m_parser,
            NULL,
            source_code,
            strlen(source_code)
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
            source_code,
            strlen(source_code)
            );
    }

    TSNode root_node = ts_tree_root_node(m_tree);
    TSTreeCursor cursor = ts_tree_cursor_new(root_node);

    for (QTextBlock block = m_document->begin(); block.isValid(); block = block.next()) {
        block.layout()->clearFormats();

        highlightBlock(cursor, block);
    }
}

void EditorBackend::highlightBlock(TSTreeCursor &cursor, QTextBlock block) {
    while (ts_node_start_point(ts_tree_cursor_current_node(&cursor)).row <= block.blockNumber()) {
        TSNode node = ts_tree_cursor_current_node(&cursor);
        int start = ts_node_start_point(node).row < block.blockNumber() ? 0 : ts_node_start_point(node).column;
        int end = ts_node_end_point(node).row > block.blockNumber() ? block.length() : ts_node_end_point(node).column;

        const char *node_type = ts_node_type(node);

        if (strcmp(node_type, "comment") == 0) {
            // editorComment
            highlightText(block, start, end, textFormat(m_commentColor));
        } else if (strcmp(node_type, "number") == 0) {
            // editorNumber
            highlightText(block, start, end, textFormat(m_numberColor));
        } else if (strcmp(node_type, "string") == 0) {
            // editorString
            highlightText(block, start, end, textFormat(m_stringColor));
        } else if (strcmp(node_type, "import") == 0 || strcmp(node_type, "property") == 0
                   || strcmp(node_type, "ui_property_modifier") == 0 || strcmp(node_type, "type_identifier") == 0
                   || strcmp(node_type, "if") == 0 || strcmp(node_type, "else") == 0
                   || strcmp(node_type, "true") == 0 || strcmp(node_type, "false") == 0) {
            // editorKeyword
            highlightText(block, start, end, textFormat(m_keywordColor));
        } else if (strcmp(node_type, "identifier") == 0 || strcmp(node_type, "property_identifier") == 0) {
            if (block.text().at(start).isLower()) // Starts with lower
                // editorProperty
                highlightText(block, start, end, textFormat(m_propertyColor));
            else // Not first item in expression
                // editorItem
                highlightText(block, start, end, textFormat(m_itemColor));
        } else if (strcmp(node_type, "ERROR") == 0) {
            // editorError
            highlightText(block, start, end, textFormat(m_errorColor, true));
        } else {
            // If node was recognized try inner node
            if (ts_tree_cursor_goto_first_child(&cursor))
                // If succeed try again
                // Possible bug here: code assumes that first child will start in same line
                continue;
        }

        if (ts_node_end_point(node).row > block.blockNumber()) break;

        // If node end is on this line we request next node
        if (!TsTreeCursorGotoNextNode(&cursor)) return;
    }
}
