#include "modulesfinder.h"

#include <QQmlEngine>
#include <QDir>
#include <QDirIterator>
#include <QQmlComponent>
#include <QQmlProperty>

ModulesFinder::ModulesFinder(QObject *parent)
    : QObject{parent} {}

QVariantMap parseQmldir(QString path) {
    QFile qmldir(path+"/qmldir");
    qmldir.open(QIODevice::ReadOnly);

    QVariantMap entry;
    entry.insert("name", "???");
    entry.insert("path", path);
    //entry.insert("path", "???");
    //qDebug() << path;
    while (!qmldir.atEnd()) {
        QByteArray line = qmldir.readLine();

        if (line.startsWith("module ")) {
            entry.insert("name", line.sliced(7));
            // break;
        }

        if (line.startsWith("typeinfo ")) {
            entry.insert("typeinfo", line.sliced(9).chopped(1));
            ModulesFinder::test(path+"/"+line.sliced(9).chopped(1));
        }

        if (line.startsWith("prefer ")) {
            QString prefer = line.sliced(7).chopped(1);
            //qDebug() << prefer;
            if (QFile::exists(prefer+"/qmldir"))
                entry.insert("path", prefer);
        }
    }
    qmldir.close();
    return entry;
}

void recSearchQmldir(QString path, QMap<QString, QVariant> &names, int depth = 0) {
    if (QFileInfo::exists(path + "/qmldir")) {
        QVariantMap entry = parseQmldir(path);
        names[entry["name"].toString()] = entry;
    }

    if (depth > 5) return;

    QDirIterator iter(path, QDir::Dirs | QDir::NoDotAndDotDot);
    while (iter.hasNext()) {
        recSearchQmldir(iter.next(), names, depth+1);
    }
}

QVariantList ModulesFinder::modules() {
    QQmlEngine *engine = qmlEngine(this);
    QMap<QString, QVariant> modules;
    for (QString &dir : engine->importPathList()) {
        if (dir.startsWith("qrc:/"))
            dir = dir.sliced(3);
        recSearchQmldir(dir, modules);
    }
    return modules.values();
}

void ModulesFinder::test(QString path) {
    static QQmlEngine typesEngine;

    QFile file(path);
    if (!file.exists())
        return;

    QQmlComponent typeinfo(&typesEngine);
    file.open(QIODevice::ReadOnly);
    typeinfo.setData(file.readAll(), QUrl());
    if (typeinfo.isReady()) {
        QObject *typeinfo2 = typeinfo.create();
        QVariant components = QQmlProperty::read(typeinfo2, "components");
        QQmlListReference list = components.value<QQmlListReference>();
        qDebug() << path << list.size();
        // for (int i = 0; i < list.size(); i++) {
        //     QObject *comp = list.at(i);
        //     qDebug() << QQmlProperty::read(comp, "name").toString();
        // }
        delete typeinfo2;
    } else if (typeinfo.isError()) {
        qDebug() << path;
        qDebug() << typeinfo.errorString();
    }
}

QString ModulesFinder::getModulePath(QString module) {
    module.replace(".", "/");
    QQmlEngine engine;
    for (QString &dir : engine.importPathList()) {
        if (dir.startsWith("qrc:/"))
            dir = dir.sliced(3);

        if (QFile::exists(dir + "/" + module + "/qmldir")) {
            // qDebug() << "found";
            return dir + "/" + module;
        }

        // TODO: check preferred path
    }
    return "";
}

QStringList ModulesFinder::getModuleComponents(QString path) {
    QFile qmldir(path + "/qmldir");
    qmldir.open(QIODevice::ReadOnly);

    QSet<QString> components;
    while (!qmldir.atEnd()) {
        QString line = qmldir.readLine();
        if (line.endsWith(".qml\n")) {
            QString name = line.first(line.indexOf(" "));
            components << name;
        }
    }
    return components.values();
}
