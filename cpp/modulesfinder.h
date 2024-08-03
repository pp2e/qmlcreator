#ifndef MODULESFINDER_H
#define MODULESFINDER_H

#include <QObject>

class ModulesFinder : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QStringList modules READ modules CONSTANT)

public:
    explicit ModulesFinder(QObject *parent = nullptr);

    QStringList modules();
    Q_INVOKABLE QStringList importPaths();
};

#endif // MODULESFINDER_H
