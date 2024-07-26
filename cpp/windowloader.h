#ifndef WINDOWLOADER_H
#define WINDOWLOADER_H

#include <QObject>
#include <QQmlEngine>
#include <QQuickWindow>
#include <QQmlComponent>

class WindowLoader : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(QQuickWindow* window READ window NOTIFY windowChanged)

public:
    explicit WindowLoader(QObject *parent = nullptr);
    ~WindowLoader();

    QString source() const;
    void setSource(const QString &newSource);

    QQuickWindow *window() const;

private:
    void loadWindow();
    void createWindow(QQmlComponent *component);

    QString m_source = "";
    QQuickWindow *m_window = nullptr;

    QQmlEngine m_engine;

signals:
    void sourceChanged();
    void windowChanged();
    void error(QString text);
};

#endif // WINDOWLOADER_H
