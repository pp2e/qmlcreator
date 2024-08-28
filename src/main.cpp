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

#include <QGuiApplication>
#include <QDateTime>
#include <QDir>
#include <QQmlApplicationEngine>
#include <QTranslator>
#include <QtGlobal>
#include "MessageHandler.h"
#include "ProjectManager.h"
#include "windowloader.h"

#include <QLoggingCategory>
#include <QSettings>

inline static void createNecessaryDir(const QString& path) {
    const QDir configDir = QDir(path);
    if (!configDir.exists()) {
        const auto success = configDir.mkpath(configDir.absolutePath());
        if (success)
            return;

        qWarning() << "Failed to create" << configDir.absolutePath();
        return;
    }
}

int main(int argc, char *argv[])
{
    qInstallMessageHandler(&MessageHandler::handler);
    QGuiApplication app(argc, argv);
    app.setApplicationVersion("1.4.0");
#ifdef UBUNTU_CLICK
    app.setOrganizationName(QStringLiteral("qmlcreator.pp2e"));
#else
    app.setApplicationName("QML Creator");
    app.setOrganizationName("pp2e");
    app.setOrganizationDomain("qmlcreator.pp2e");
#endif

    // const QString configPath = QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation);
    // const QString cachePath = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
    createNecessaryDir(QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation));
    createNecessaryDir(QStandardPaths::writableLocation(QStandardPaths::CacheLocation));
    createNecessaryDir(ProjectManager::baseFolderPath(""));

    QTranslator translator;
    translator.load("qmlcreator_" + QLocale::system().name(), ":/QmlCreator/resources/translations");
    app.installTranslator(&translator);

    uint GRID_UNIT_PX = qgetenv("GRID_UNIT_PX").toUInt();
    if (GRID_UNIT_PX == 0) {
        GRID_UNIT_PX = 8;
    }

    // Use here the same thing we use to preview
    WindowLoader loader;

    QObject::connect(&loader, &WindowLoader::error,
                     [&](QString error) {
                         qCritical() << error;
                         if (loader.source() == "qrc:/qt/qml/QmlCreator/qml/error.qml") {
                             qFatal() << "Cannot load error window";
                             app.exit(1);
                             return;
                         }
                         loader.load("qrc:/qt/qml/QmlCreator/qml/error.qml", {{"text", error}});
                     });

    QObject::connect(&loader, &WindowLoader::windowChanged,
                     [&loader]() {
                         if (loader.window()) {
                             loader.window()->show();
                             MessageHandler::setWindow(loader.window());
                         }
                     });

    const QString qtVersion = QT_VERSION_STR;
    const QString buildDateTime = QStringLiteral("%1 %2").arg(__DATE__, __TIME__);
    loader.engine()->rootContext()->setContextProperty("qtVersion", qtVersion);
    loader.engine()->rootContext()->setContextProperty("buildDateTime", buildDateTime);

    // loader.engine()->rootContext()->setContextProperty("configPath", configPath);
    // loader.engine()->rootContext()->setContextProperty("cachePath", cachePath);

    loader.engine()->rootContext()->setContextProperty("GRID_UNIT_PX", GRID_UNIT_PX);

#if !defined(Q_OS_ANDROID)
    loader.engine()->rootContext()->setContextProperty("platformResizesView", true);
#else
    loader.engine()->rootContext()->setContextProperty("platformResizesView", false);
#endif

#if defined(Q_OS_IOS) || defined(Q_OS_ANDROID)
    loader.engine()->rootContext()->setContextProperty("platformHasNativeCopyPaste", true);
    loader.engine()->rootContext()->setContextProperty("platformHasNativeDragHandles", true);
#else
    loader.engine()->rootContext()->setContextProperty("platformHasNativeCopyPaste", false);
    loader.engine()->rootContext()->setContextProperty("platformHasNativeDragHandles", false);
#endif

    QSettings settings(ProjectManager::baseFolderPath("settings.ini"), QSettings::IniFormat);
    QString entryPoint = settings.value("qmlEntryPoint").toString();

    if (entryPoint != "") {
        qDebug() << "Loading from" << entryPoint;
        loader.load(entryPoint);
    } else {
        qDebug() << "Using inbuilt main.qml";
        loader.load("qrc:/qt/qml/QmlCreator/qml/main.qml");
    }

    return app.exec();
}
