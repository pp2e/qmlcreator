#ifndef EDITORBACKEND_H
#define EDITORBACKEND_H

#include <QObject>
#include <QQuickTextDocument>
#include <QTextFormat>
#include <private/qquicktextedit_p.h>

struct TSNode;
struct TSPoint;
struct TSTreeCursor;
struct TSParser;
struct TSTree;

class EditorBackend : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QQuickTextEdit* textEdit WRITE setTextEdit)

    Q_PROPERTY(QColor commentColor   MEMBER m_commentColor   NOTIFY commentColorChanged)
    Q_PROPERTY(QColor numberColor    MEMBER m_numberColor    NOTIFY numberColorChanged)
    Q_PROPERTY(QColor stringColor    MEMBER m_stringColor    NOTIFY stringColorChanged)
    Q_PROPERTY(QColor keywordColor   MEMBER m_keywordColor   NOTIFY keywordColorChanged)
    Q_PROPERTY(QColor itemColor      MEMBER m_itemColor      NOTIFY itemColorChanged)
    Q_PROPERTY(QColor propertyColor  MEMBER m_propertyColor  NOTIFY propertyColorChanged)
    Q_PROPERTY(QColor errorColor     MEMBER m_errorColor     NOTIFY errorColorChanged)

public:
    explicit EditorBackend(QObject *parent = nullptr);
    ~EditorBackend();

    // general
    void textChanged(int from, int charsRemoved, int charsAdded);

    // highlight text
    void highlightText(QTextBlock block, int start, int end, QTextCharFormat format);
    void highlightBlock(TSTreeCursor &cursor, QTextBlock block);

    // preedit input
    void setTextEdit(QQuickTextEdit *textEdit);
    bool eventFilter(QObject *object, QEvent *event) override;

private:
    // general
    TSParser *m_parser = nullptr;
    TSTree *m_tree = nullptr;
    // To count line and column of position from previous text state
    QList<int> m_prevBlockLengths;
    QQuickTextEdit *m_textEdit = nullptr;
    QTextDocument *m_document = nullptr;

    // highlight text
    QColor m_commentColor;
    QColor m_numberColor;
    QColor m_stringColor;
    QColor m_keywordColor;
    QColor m_itemColor;
    QColor m_propertyColor;
    QColor m_errorColor;

signals:
    void commentColorChanged();
    void numberColorChanged();
    void stringColorChanged();
    void keywordColorChanged();
    void itemColorChanged();
    void propertyColorChanged();
    void errorColorChanged();
};

#endif // EDITORBACKEND_H
