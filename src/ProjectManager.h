/****************************************************************************
**
** Copyright (C) 2013-2015 Oleg Yadrov
**
** Licensed under the Apache License, Version 2.0 (the "License");
** you may not use this file except in compliance with the License.
** You may obtain a copy of the License at
**
** http://www.apache.org/licenses/LICENSE-2.0
**
** Unless required by applicable law or agreed to in writing, software
** distributed under the License is distributed on an "AS IS" BASIS,
** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
** See the License for the specific language governing permissions and
** limitations under the License.
**
****************************************************************************/

#ifndef PROJECTMANAGER_H
#define PROJECTMANAGER_H

#include <QObject>
#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <QIODevice>
#include <QStandardPaths>
#include <QTextStream>
#include <QQmlEngine>

class ProjectManager : public QObject
{
    Q_OBJECT
    
    Q_PROPERTY(QString settingsPath READ settingsPath CONSTANT)
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit ProjectManager(QQmlEngine *engine, QObject *parent = 0);

    // project management
    Q_INVOKABLE void createProject(QString path, QString projectName);
    Q_INVOKABLE void restoreExamples(QString path);
    Q_INVOKABLE void restoreQmlFiles(QString path);

    // current project
    Q_INVOKABLE QVariantList files(QString subdir);
    Q_INVOKABLE void createFile(QString filePath, QString fileExtension);
    Q_INVOKABLE void removeFile(QString filePath);
    Q_INVOKABLE void createDir(QString dirPath);
    Q_INVOKABLE bool fileExists(QString filePath);

    // // current file
    Q_INVOKABLE QString getFilePath(QString filePath);
    Q_INVOKABLE QString getFileContent(QString filePath);
    Q_INVOKABLE void saveFileContent(QString filePath, QString content);

    // QML engine stuff
    Q_INVOKABLE void clearComponentCache();

    // singleton type provider function
    static ProjectManager *create(QQmlEngine *engine, QJSEngine *scriptEngine);
    
    // for main.qml selection in main.cpp
    Q_INVOKABLE static QString baseFolderPath(QString folder);
    
    QString static settingsPath();

private:
    void recursiveCopyDir(QDir source, QDir target);
    QString newFileContent(QString fileType);

    // QML engine stuff
    QQmlEngine *m_qmlEngine;

signals:
    void error(QString description);
};

#endif // PROJECTMANAGER_H
