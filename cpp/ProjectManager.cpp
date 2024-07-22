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

#include "ProjectManager.h"

#include <QDebug>

ProjectManager::ProjectManager(QObject *parent) :
    QObject(parent)
{
    QDir().mkpath(baseFolderPath("Projects"));
    QDir().mkpath(baseFolderPath("Examples"));
    QDir().mkpath(baseFolderPath("QmlCreator"));
}

QString ProjectManager::baseFolder()
{
    return m_baseFolder;
}

void ProjectManager::setBaseFolder(QString baseFolder)
{
    if (m_baseFolder != baseFolder)
    {
        m_baseFolder = baseFolder;
        emit baseFolderChanged();
    }
}

QStringList ProjectManager::projects()
{
    QDir dir(baseFolderPath(m_baseFolder));
    QStringList projects;
    QFileInfoList folders = dir.entryInfoList(QDir::AllDirs | QDir::NoDotAndDotDot);

    foreach(QFileInfo folder, folders) {
        QString folderName = folder.fileName();
        projects.push_back(folderName);
    }

    return projects;
}

void ProjectManager::createProject(QString projectName)
{
    QDir dir(baseFolderPath("Projects"));
    if (dir.mkpath(projectName))
    {
        QFile file(baseFolderPath("Projects") + QDir::separator() + projectName + QDir::separator() + "main.qml");
        if (file.open(QIODevice::WriteOnly | QIODevice::Text))
        {
            QString fileContent = "// Project \"" + projectName + "\"\n" + newFileContent("main");
            QTextStream textStream(&file);
            textStream<<fileContent;
        }
        else
        {
            qWarning() << "Unable to create file \"main.qml\"";
            emit error(QString("Unable to create file \"main.qml\""));
        }
    }
    else
    {
        qWarning() << "Failed to create folder" << dir.absolutePath();
        emit error(QString("Unable to create folder \"%1\".").arg(projectName));
    }
}

void ProjectManager::removeProject(QString projectName)
{
    QDir dir(baseFolderPath(m_baseFolder) + QDir::separator() + projectName);
    dir.removeRecursively();
}

bool ProjectManager::projectExists(QString projectName)
{
    QFileInfo checkFile(baseFolderPath("Projects") + QDir::separator() + projectName);
    return checkFile.exists();
}

void ProjectManager::restoreExamples()
{
    QDir deviceExamplesDir(baseFolderPath(m_baseFolder));
    deviceExamplesDir.removeRecursively();

    QDir qrcExamplesDir;
    if (m_baseFolder == "Examples")
        qrcExamplesDir = QDir(":/QmlCreator/examples");
    else if (m_baseFolder == "QmlCreator")
        qrcExamplesDir = QDir(":/QmlCreator/qml");

    recursiveCopyDir(qrcExamplesDir, deviceExamplesDir);
}

QString ProjectManager::projectName()
{
    return m_projectName;
}

void ProjectManager::setProjectName(QString projectName)
{
    if (m_projectName != projectName)
    {
        m_projectName = projectName;
        emit projectNameChanged();
    }
}

// QString ProjectManager::subDir()
// {
//     return m_subdir;
// }

// void ProjectManager::setSubDir(QString dir)
// {
//     if (m_subdir != dir)
//     {
//         m_subdir = dir;
//         emit subDirChanged();
//     }
// }

QVariantList ProjectManager::files(QString subdir)
{
    QDir dir(baseFolderPath(m_baseFolder) +
             QDir::separator() + m_projectName + QDir::separator() + subdir);
    QVariantList projectFiles;
    QFileInfoList files = dir.entryInfoList(QDir::Files | QDir::Dirs | QDir::NoDotAndDotDot);

    foreach(QFileInfo file, files) {
        qDebug() << file.absolutePath();
        if (!file.isDir() && (file.suffix() == "qml" || file.suffix() == "js"))
        {
            QVariantMap fileEntry;
            QString fileName = file.fileName();
            fileEntry.insert("name", fileName);
            fileEntry.insert("isDir", false);
            projectFiles.push_back(fileEntry);
        } else if (file.isDir()) {
            QVariantMap dirEntry;
            QString fileName = file.fileName();
            dirEntry.insert("name", fileName);
            dirEntry.insert("isDir", true);
            projectFiles.push_back(dirEntry);
        }
    }

    return projectFiles;
}

void ProjectManager::createFile(QString fileName, QString fileExtension)
{
    QFile file(baseFolderPath(m_baseFolder) +
               QDir::separator() + m_projectName +
               // QDir::separator() + m_subdir +
               QDir::separator() + fileName + "." + fileExtension);
    if (file.open(QIODevice::WriteOnly | QIODevice::Text))
    {
        QTextStream textStream(&file);
        textStream<<newFileContent(fileExtension);
    }
    else
    {
        emit error(QString("Unable to create file \"%1.%2\"").arg(fileName, fileExtension));
    }
}

void ProjectManager::removeFile(QString fileName)
{
    const QString filePath =
            baseFolderPath(m_baseFolder) +
            QDir::separator() + m_projectName +
            // QDir::separator() + m_subdir +
            QDir::separator() + fileName;
    qDebug() << "Removing" << filePath;

    const bool isDir = QFileInfo(filePath).isDir();
    if (isDir) {
        QDir(filePath).removeRecursively();
    } else {
       QDir().remove(filePath);
    }
}

void ProjectManager::createDir(QString dirName)
{
    const QString fullPath =
            baseFolderPath(m_baseFolder) +
            QDir::separator() + m_projectName +
            // QDir::separator() + m_subdir +
            QDir::separator() + dirName;
    qDebug() << "Creating dir" << fullPath;
    QDir().mkpath(fullPath);
}

bool ProjectManager::fileExists(QString filePath)
{
    QFileInfo checkFile(baseFolderPath(m_baseFolder) +
                        QDir::separator() + m_projectName +
                        QDir::separator() + filePath);
    return checkFile.exists();
}

// QString ProjectManager::fileName()
// {
//     return m_fileName;
// }

// QString ProjectManager::fileFormat()
// {
//     return m_fileFormat;
// }

// void ProjectManager::setFileName(QString fileName)
// {
//     if (m_fileName != fileName)
//     {
//         QFileInfo fileInfo(baseFolderPath(m_baseFolder) +
//                            QDir::separator() + m_projectName +
//                            QDir::separator() + m_subdir +
//                            QDir::separator() + fileName);

//         m_fileName = fileName;
//         m_fileFormat = fileInfo.suffix();

//         emit fileNameChanged();
//         emit fileFormatChanged();
//     }
// }

QString ProjectManager::getFilePath(QString filePath)
{
    return "file:///" + baseFolderPath(m_baseFolder) +
            QDir::separator() + m_projectName +
            QDir::separator() + filePath;
}

QString ProjectManager::getFileContent(QString filePath)
{
    QFile file(baseFolderPath(m_baseFolder) +
               QDir::separator() + m_projectName +
               QDir::separator() + filePath);
    file.open(QIODevice::ReadOnly | QIODevice::Text);
    QTextStream textStream(&file);
    QString fileContent = textStream.readAll().trimmed();
    return fileContent;
}

void ProjectManager::saveFileContent(QString filePath, QString content)
{
    QFile file(baseFolderPath(m_baseFolder) +
               QDir::separator() + m_projectName +
               QDir::separator() + filePath);
    file.open(QIODevice::WriteOnly | QIODevice::Text);
    QTextStream textStream(&file);
    textStream<<content;
}

QQmlApplicationEngine *ProjectManager::m_qmlEngine = Q_NULLPTR;

void ProjectManager::setQmlEngine(QQmlApplicationEngine *engine)
{
    ProjectManager::m_qmlEngine = engine;
}

void ProjectManager::clearComponentCache()
{
    ProjectManager::m_qmlEngine->clearComponentCache();
}

QObject *ProjectManager::projectManagerProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    ProjectManager *projectManager = new ProjectManager();
    return projectManager;
}

void ProjectManager::recursiveCopyDir(QDir source, QDir target)
{
    target.mkpath(".");

    QFileInfoList folders = source.entryInfoList(QDir::AllDirs | QDir::NoDotAndDotDot);
    for (QFileInfo folder : folders) {
        QDir source2(folder.filePath());
        QDir target2(target.absoluteFilePath(folder.fileName()));
        recursiveCopyDir(source2, target2);
    }

    QFileInfoList files = source.entryInfoList(QDir::Files);
    for (QFileInfo file : files) {
        qDebug() << file << target.absoluteFilePath(file.fileName());
        QFile::copy(source.absoluteFilePath(file.fileName()),
                    target.absoluteFilePath(file.fileName()));

        QFile::setPermissions(target.absoluteFilePath(file.fileName()),
                                  QFileDevice::ReadOwner | QFileDevice::WriteOwner |
                                  QFileDevice::ReadUser  | QFileDevice::WriteUser  |
                                  QFileDevice::ReadGroup | QFileDevice::WriteGroup |
                                  QFileDevice::ReadOther | QFileDevice::WriteOther
                                  );

    }
}

QString ProjectManager::baseFolderPath(QString folder)
{
#ifndef UBUNTU_CLICK
    QString folderPath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation) +
#else
    QString folderPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) +
#endif
                         QDir::separator() +
                         "QML Projects";

    if (!folder.isEmpty())
    {
        folderPath += QDir::separator() + folder;
    }

    return folderPath;
}

QString ProjectManager::newFileContent(QString fileType)
{
    QString fileName;

    if (fileType == "main")
        fileName = "MainFile.qml";
    else if (fileType == "qml")
        fileName = "QmlFile.qml";
    else if (fileType == "js")
        fileName = "JsFile.js";

    QString fileContent;

    if (!fileName.isEmpty())
    {
        QFile file(":/QmlCreator/resources/templates/" + fileName);
        file.open(QIODevice::ReadOnly | QIODevice::Text);
        QTextStream textStream(&file);
        fileContent = textStream.readAll().trimmed();
    }

    return fileContent;
}
