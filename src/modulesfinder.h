#ifndef MODULESFINDER_H
#define MODULESFINDER_H

#include <QObject>
#include <QtQmlIntegration>

class ModulesFinder : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QVariantList modules READ modules CONSTANT)

public:
    explicit ModulesFinder(QObject *parent = nullptr);

    QVariantList modules();
    Q_INVOKABLE static void test(QString path);
};

#endif // MODULESFINDER_H
