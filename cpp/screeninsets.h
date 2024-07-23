#ifndef SCREENINSETS_H
#define SCREENINSETS_H

#include <QObject>

class ScreenInsets : public QObject
{
    Q_OBJECT
public:
    explicit ScreenInsets(QObject *parent = nullptr);

signals:
};

#endif // SCREENINSETS_H
