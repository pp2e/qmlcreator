#include "modulesfinder.h"

#include <QQmlEngine>
#include <QDir>
#include <QDirIterator>

ModulesFinder::ModulesFinder(QObject *parent)
    : QObject{parent} {}

void recSearchQmldir(QString path, QStringList &names, int depth = 0) {
    qDebug() << path;
    QString qmldirPath = path + QDir::separator() + "qmldir";
    if (QFileInfo::exists(qmldirPath)) {
        qDebug() << "found qmldir";
        QFile qmldir(qmldirPath);
        qmldir.open(QIODevice::ReadOnly);
        // TODO: probably can not read all file
        QByteArrayList lines = qmldir.readAll().split('\n');
        for (const QByteArray &line : lines) {
            if (line.startsWith("module ")) {
                names << line.sliced(7);
            }
        }
    }

    if (depth > 5) return;

    QDirIterator iter(path, QDir::Dirs | QDir::NoDotAndDotDot);
    while (iter.hasNext()) {
        recSearchQmldir(iter.next(), names, depth+1);
    }
}

QStringList ModulesFinder::modules() {
    QQmlEngine *engine = qmlEngine(this);
    QStringList modules;
    for (const QString &dir : engine->importPathList()) {
        recSearchQmldir(dir, modules);
    }
    return modules;
}

QStringList ModulesFinder::importPaths() {
    return qmlEngine(this)->importPathList();
}
