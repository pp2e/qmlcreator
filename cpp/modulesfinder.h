#ifndef MODULESFINDER_H
#define MODULESFINDER_H

#include <QObject>

class ModulesFinder : public QObject
{
    Q_OBJECT
public:
    explicit ModulesFinder(QObject *parent = nullptr);

    Q_PROPERTY(QStringList modules READ modules CONSTANT)
    QStringList modules();
};

#endif // MODULESFINDER_H
