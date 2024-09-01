#ifndef EDITORBACKEND_H
#define EDITORBACKEND_H

#include <QObject>
#include <QQuickTextDocument>
#include <QTextFormat>

struct TSNode;
struct TSPoint;
struct TSTreeCursor;
struct TSParser;
struct TSTree;

class EditorBackend : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QQuickTextDocument* document WRITE setQuickDocument)

    // Q_PROPERTY(QColor normalColor    MEMBER m_normalColor    NOTIFY normalColorChanged)
    Q_PROPERTY(QColor commentColor   MEMBER m_commentColor   NOTIFY commentColorChanged)
    Q_PROPERTY(QColor numberColor    MEMBER m_numberColor    NOTIFY numberColorChanged)
    Q_PROPERTY(QColor stringColor    MEMBER m_stringColor    NOTIFY stringColorChanged)
    // Q_PROPERTY(QColor operatorColor  MEMBER m_operatorColor  NOTIFY operatorColorChanged)
    Q_PROPERTY(QColor keywordColor   MEMBER m_keywordColor   NOTIFY keywordColorChanged)
    // Q_PROPERTY(QColor builtInColor   MEMBER m_builtInColor   NOTIFY builtInColorChanged)
    // Q_PROPERTY(QColor markerColor    MEMBER m_markerColor    NOTIFY markerColorChanged)
    Q_PROPERTY(QColor itemColor      MEMBER m_itemColor      NOTIFY itemColorChanged)
    Q_PROPERTY(QColor propertyColor  MEMBER m_propertyColor  NOTIFY propertyColorChanged)
    Q_PROPERTY(QColor errorColor     MEMBER m_errorColor     NOTIFY errorColorChanged)

public:
    explicit EditorBackend(QObject *parent = nullptr);
    ~EditorBackend();

    void setQuickDocument(QQuickTextDocument *quickDocument);
    void highlightText(QTextBlock block, int start, int end, QTextCharFormat format);
    void textChanged(int from, int charsRemoved, int charsAdded);

    void highlightBlock(TSTreeCursor &cursor, QTextBlock block);

private:
    TSParser *m_parser = nullptr;
    TSTree *m_tree = nullptr;
    // To count line and column of position from previous text state
    QList<int> m_prevBlockLengths;
    QQuickTextDocument *m_quickDocument = nullptr;
    QTextDocument *m_document = nullptr;

    // QColor m_normalColor;
    QColor m_commentColor;
    QColor m_numberColor;
    QColor m_stringColor;
    // QColor m_operatorColor;
    QColor m_keywordColor;
    // QColor m_builtInColor;
    // QColor m_markerColor;
    QColor m_itemColor;
    QColor m_propertyColor;
    QColor m_errorColor;

signals:
    // void normalColorChanged();
    void commentColorChanged();
    void numberColorChanged();
    void stringColorChanged();
    // void operatorColorChanged();
    void keywordColorChanged();
    // void builtInColorChanged();
    // void markerColorChanged();
    void itemColorChanged();
    void propertyColorChanged();
    void errorColorChanged();
};

#endif // EDITORBACKEND_H
