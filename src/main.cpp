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
    // QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    qInstallMessageHandler(&MessageHandler::handler);
    QGuiApplication app(argc, argv);
    app.setApplicationVersion("1.4.0");
#ifdef UBUNTU_CLICK
    app.setOrganizationName(QStringLiteral("me.fredl.qmlcreator"));
#else
    app.setApplicationName("QML Creator");
    app.setOrganizationName("wearyinside");
    app.setOrganizationDomain("com.wearyinside.qmlcreator");
#endif

    const QString configPath =
            QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation) +
            QDir::separator();
    const QString cachePath =
            QStandardPaths::writableLocation(QStandardPaths::CacheLocation) +
            QDir::separator();

    createNecessaryDir(configPath);
    createNecessaryDir(cachePath);

    QTranslator translator;
    translator.load("qmlcreator_" + QLocale::system().name(), ":/QmlCreator/resources/translations");
    app.installTranslator(&translator);

    uint GRID_UNIT_PX = qgetenv("GRID_UNIT_PX").toUInt();
    if (GRID_UNIT_PX == 0) {
        GRID_UNIT_PX = 8;
    }

    //QQmlApplicationEngine engine;
    WindowLoader loader;

    const QString qtVersion = QT_VERSION_STR;
    const QString buildDateTime = QStringLiteral("%1 %2").arg(__DATE__, __TIME__);
    loader.engine()->rootContext()->setContextProperty("qtVersion", qtVersion);
    loader.engine()->rootContext()->setContextProperty("buildDateTime", buildDateTime);

    loader.engine()->rootContext()->setContextProperty("configPath", configPath);
    loader.engine()->rootContext()->setContextProperty("cachePath", cachePath);

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

    // Load user's custom main.qml if we can
    if (QFile(ProjectManager::baseFolderPath("QmlCreator") + "/Main.qml").exists())
        //engine.load(QUrl(ProjectManager::baseFolderPath("QmlCreator") + "/Main.qml"));
        loader.setSource(ProjectManager::baseFolderPath("QmlCreator") + "/Main.qml");
    else
        //engine.loadFromModule("QmlCreator", "Main");
        loader.setSource("qrc:/qt/qml/QmlCreator/qml/Main.qml");
        
    QObject::connect(&loader, &WindowLoader::windowChanged,
                     [&loader]() { if (loader.window()) loader.window()->show(); });

    //MessageHandler::setQmlEngine(loader.engine());
    return app.exec();
}
