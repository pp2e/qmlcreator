#ifndef SCREENINSETS_H
#define SCREENINSETS_H

#include <QObject>
#include <QQuickWindow>

class ScreenInsets : public QObject
{
    Q_OBJECT

    Q_PROPERTY(int top READ top)
    Q_PROPERTY(int bottom READ bottom)
    Q_PROPERTY(int left READ left)
    Q_PROPERTY(int right READ right)

    Q_PROPERTY(QQuickWindow *window WRITE setWindow)

public:
    explicit ScreenInsets(QQuickWindow *window = nullptr);

    int top();
    int bottom();
    int left();
    int right();

    void setWindow(QQuickWindow *window);

private:
    QQuickWindow *m_window;
};

#endif // SCREENINSETS_H
