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

public:
    explicit WindowLoader(QObject *parent = nullptr);
    ~WindowLoader();

    QString source() const;
    void setSource(const QString &newSource);

    QColor color() const;
    void setColor(const QColor color);

    QQuickWindow *window() const;
    
    QQmlEngine *engine() const;

private:
    void loadWindow();
    void createWindow(QQmlComponent *component);

    QString m_source = "";
    QColor m_color;
    QQuickWindow *m_window = nullptr;

    QQmlEngine m_engine;

signals:
    void sourceChanged();
    void colorChanged();
    void windowChanged();
    void error(QString text);
};

#endif // WINDOWLOADER_H
