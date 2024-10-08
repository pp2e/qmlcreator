#ifndef WINDOWLOADER_H
#define WINDOWLOADER_H

#include <QObject>
#include <QQmlEngine>
#include <QQuickWindow>
#include <QQmlComponent>

class WindowLoader : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QString source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(QColor color READ color WRITE setColor NOTIFY colorChanged)

    Q_PROPERTY(QQuickWindow* window READ window NOTIFY windowChanged)
    Q_PROPERTY(bool hideWindow READ hideWindow WRITE setHideWindow NOTIFY hideWindowChanged)

public:
    explicit WindowLoader(QObject *parent = nullptr);
    ~WindowLoader();

    QString source() const;
    void setSource(const QString &source);

    void load(const QString &source, QVariantMap properties = {});

    QColor color() const;
    void setColor(const QColor color);

    QQuickWindow *window() const;
    
    bool hideWindow();
    void setHideWindow(bool hideWindow);
    
    QQmlEngine *engine();

private:
    void createWindow(QQmlComponent *component);

    QString m_source = "";
    QVariantMap m_properties;
    QColor m_color;
    QQuickWindow *m_window = nullptr;
    bool m_hideWindow;

    QQmlEngine m_engine;

signals:
    void sourceChanged();
    void colorChanged();
    void windowChanged();
    void hideWindowChanged();
    void error(QString text);
};

#endif // WINDOWLOADER_H
