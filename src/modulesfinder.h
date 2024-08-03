#ifndef MODULESFINDER_H
#define MODULESFINDER_H

#include <QObject>
#include <QtQmlIntegration>

class ModulesFinder : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QStringList modules READ modules CONSTANT)

public:
    explicit ModulesFinder(QObject *parent = nullptr);

    QStringList modules();
    Q_INVOKABLE QStringList importPaths();
};

#endif // MODULESFINDER_H
