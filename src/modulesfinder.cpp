#include "modulesfinder.h"

#include <QQmlEngine>
#include <QDir>
#include <QDirIterator>
#include <QQmlComponent>
#include <QQmlProperty>

ModulesFinder::ModulesFinder(QObject *parent)
    : QObject{parent} {}

void recSearchQmldir(QString path, QMap<QString, QVariant> &names, int depth = 0) {
    QString qmldirPath = path + QDir::separator() + "qmldir";
    if (QFileInfo::exists(qmldirPath)) {
        QFile qmldir(qmldirPath);
        qmldir.open(QIODevice::ReadOnly);

        QVariantMap entry;
        entry.insert("name", "???");
        // entry.insert("path", path);
        entry.insert("path", "???");
        qDebug() << path;
        while (!qmldir.atEnd()) {
            QByteArray line = qmldir.readLine();

            if (line.startsWith("module ")) {
                entry.insert("name", line.sliced(7));
                // break;
            }

            if (line.startsWith("typeinfo ")) {
                entry.insert("path", path+"/"+line.sliced(9).chopped(1));
                ModulesFinder::test(path+"/"+line.sliced(9).chopped(1));
                // break;
            }

            // TODO here check preferred path
        }
        names[entry["name"].toString()] = entry;
        qmldir.close();
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
    if (path.contains("/kde/plasma/private/dict"))
        return;

    if (path.contains("/QtWebEngine"))
        return;

    if (path.contains("/QtWebView"))
        return;

    static QQmlEngine typesEngine;

    if (!QFile::exists(path))
        return;

    QQmlComponent *typeinfo = new QQmlComponent(&typesEngine, path, QQmlComponent::CompilationMode::PreferSynchronous);
    if (typeinfo->isReady()) {
        QObject *typeinfo2 = typeinfo->create();
        QVariant components = QQmlProperty::read(typeinfo2, "components");
        QQmlListReference list = components.value<QQmlListReference>();
        // for (int i = 0; i < list.size(); i++) {
        //     QObject *comp = list.at(i);
        //     qDebug() << QQmlProperty::read(comp, "name").toString();
        // }
        delete typeinfo2;
        delete typeinfo;
    } else if (typeinfo->isError()) {
        qDebug() << path;
        qDebug() << typeinfo->errorString();
        delete typeinfo;
    } else {
    //     QObject::connect(typeinfo, &QQmlComponent::statusChanged,
    //                      [=] () {
    //                          qDebug() << "status chamged";
    //                          QObject *typeinfo2 = typeinfo->create();
    //                          qDebug() << typeinfo2->metaObject()->className();
    //                          delete typeinfo2;
    //                          delete typeinfo;
    //                      });
    }
}
