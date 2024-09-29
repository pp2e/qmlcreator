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
    qWarning() << "module not fount" << module;
    return "";
}

QString ModulesFinder::getQMLModulePath() {
    QQmlEngine engine;
    for (QString &dir : engine.importPathList()) {
        if (dir.startsWith("qrc:/"))
            dir = dir.sliced(3);

        if (QFile::exists(dir + "/builtins.qmltypes"))
            return dir + "/builtins.qmltypes";
    }
    qWarning() << "module not fount QML";
    return "";
}

QStringList ModulesFinder::getModuleDependencies(QString path) {
    QStringList imports;

    QFile qmldir(path + "/qmldir");
    qmldir.open(QIODevice::ReadOnly);

    while (!qmldir.atEnd()) {
        QString line = qmldir.readLine().chopped(1);
        if (line.startsWith("default import ")) {
            line = line.sliced(15);
            imports << line.first(line.indexOf(' '));
        } else if (line.startsWith("import ")) {
            line = line.sliced(7);
            imports << line.first(line.indexOf(' '));
        }
        // Do not return "optional import"'s
    }

    qmldir.close();
    return imports;
}

QMap<QString, int> getTypeinfoComponents(QString path) {
    QMap<QString, int> components;
    QFile file(path);
    if (!file.exists())
        return {};

    static QQmlEngine typesEngine;
    QQmlComponent typeinfo(&typesEngine);
    file.open(QIODevice::ReadOnly);
    typeinfo.setData(file.readAll(), QUrl());
    file.close();
    if (typeinfo.isReady()) {
        QObject *typeinfo2 = typeinfo.create();
        QVariant module = QQmlProperty::read(typeinfo2, "components");
        QQmlListReference list = module.value<QQmlListReference>();
        // qDebug() << path << list.size();
        for (int i = 0; i < list.size(); i++) {
            QObject *comp = list.at(i);
            // qDebug() << QQmlProperty::read(comp, "name").toString();
            if (QQmlProperty::read(comp, "isCreatable").toBool()) {
                QStringList exports = QQmlProperty::read(comp, "exports").toStringList();
                if (!exports.isEmpty()) {
                    QString name = exports.last();
                    components.insert(name.first(name.indexOf(' ')).sliced(name.indexOf('/')+1), 0);
                }
            }
        }
        delete typeinfo2;
    } else if (typeinfo.isError()) {
        qDebug() << path;
        qDebug() << typeinfo.errorString();
    }
    return components;
}

QStringList ModulesFinder::getModuleComponents(QString path) {
    if (path == "QML")
        return getTypeinfoComponents(getQMLModulePath()).keys();

    QFile qmldir(path + "/qmldir");
    qmldir.open(QIODevice::ReadOnly);

    QMap<QString, int> components;

    QString typeinfo;
    QString prefer;
    while (!qmldir.atEnd()) {
        QString line = qmldir.readLine().chopped(1);
        if (line.endsWith(".qml")) {
            QString name = line.first(line.indexOf(" "));
            components.insert(name, 0);
        } else if (line.startsWith("typeinfo ")) {
            // qDebug() << "module has typeinfo" << line.sliced(9);
            typeinfo = path + "/" + line.sliced(9);
        } else if (line.startsWith("prefer ")) {
            if (line.sliced(7) != path)
                prefer = line.sliced(7);
            // if (line.sliced(7) != path) {
            //     qDebug() << "use" << line.sliced(7) << "instead of" << path;
            //     return getModuleComponents(line.sliced(7));
            // }
        }
    }
    qmldir.close();

    if (!typeinfo.isEmpty()) {
        components.insert(getTypeinfoComponents(typeinfo));
    }

    return components.keys();
}
