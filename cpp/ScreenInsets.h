#ifndef SCREENINSETS_H
#define SCREENINSETS_H

#include <QObject>
#include <QQuickWindow>

class ScreenInsets : public QObject
{
    Q_OBJECT

    Q_PROPERTY(int top READ top NOTIFY insetsChanged)
    Q_PROPERTY(int bottom READ bottom NOTIFY insetsChanged)
    Q_PROPERTY(int left READ left NOTIFY insetsChanged)
    Q_PROPERTY(int right READ right NOTIFY insetsChanged)

    Q_PROPERTY(QQuickWindow *window WRITE setWindow REQUIRED)

public:
    explicit ScreenInsets(QQuickWindow *window = nullptr);

    int top();
    int bottom();
    int left();
    int right();

    void setWindow(QQuickWindow *window);

private:
    QQuickWindow *m_window;
    
signals:
    void insetsChanged();
};

#endif // SCREENINSETS_H
