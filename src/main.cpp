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
#include <QQuickView>
#include "MessageHandler.h"
#include "ProjectManager.h"
#include "SyntaxHighlighter.h"
#include "linenumbershelper.h"
#include "ScreenInsets.h"
#include "modulesfinder.h"
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

    qmlRegisterSingletonType<ProjectManager>("ProjectManager", 1, 1, "ProjectManager", &ProjectManager::projectManagerProvider);
    qmlRegisterType<SyntaxHighlighter>("SyntaxHighlighter", 1, 1, "SyntaxHighlighter");
    qmlRegisterType<LineNumbersHelper>("LineNumbersHelper", 1, 1, "LineNumbersHelper");
    qmlRegisterType<ScreenInsets>("ScreenInsets", 1, 0, "ScreenInsets");
    qmlRegisterType<WindowLoader>("WindowLoader", 1, 0, "WindowLoader");
    qmlRegisterType<ModulesFinder>("ModulesFinder", 1, 0, "ModulesFinder");

    uint GRID_UNIT_PX = qgetenv("GRID_UNIT_PX").toUInt();
    if (GRID_UNIT_PX == 0) {
        GRID_UNIT_PX = 8;
    }

    QQuickView view;
    //QQmlApplicationEngine engine;

    const QString qtVersion = QT_VERSION_STR;
    const QString buildDateTime = QStringLiteral("%1 %2").arg(__DATE__, __TIME__);
    view.engine()->rootContext()->setContextProperty("qtVersion", qtVersion);
    view.engine()->rootContext()->setContextProperty("buildDateTime", buildDateTime);

    view.engine()->rootContext()->setContextProperty("configPath", configPath);
    view.engine()->rootContext()->setContextProperty("cachePath", cachePath);

    view.engine()->rootContext()->setContextProperty("GRID_UNIT_PX", GRID_UNIT_PX);

#if !defined(Q_OS_ANDROID)
    view.engine()->rootContext()->setContextProperty("platformResizesView", true);
#else
    view.engine()->rootContext()->setContextProperty("platformResizesView", false);
#endif

#if defined(Q_OS_IOS) || defined(Q_OS_ANDROID)
    view.engine()->rootContext()->setContextProperty("platformHasNativeCopyPaste", true);
    view.engine()->rootContext()->setContextProperty("platformHasNativeDragHandles", true);
#else
    view.engine()->rootContext()->setContextProperty("platformHasNativeCopyPaste", false);
    view.engine()->rootContext()->setContextProperty("platformHasNativeDragHandles", false);
#endif

    // Load user's custom main.qml if we can
    if (QFile(ProjectManager::baseFolderPath("QmlCreator") + "/main.qml").exists())
        //engine.load(QUrl(ProjectManager::baseFolderPath("QmlCreator") + "/main.qml"));
        view.setSource(QUrl(ProjectManager::baseFolderPath("QmlCreator") + "/main.qml"));
    else
        //engine.load(QUrl("qrc:/qt/qml/QmlCreator/qml/main.qml"));
        view.setSource(QUrl("qrc:/qt/qml/QmlCreator/qml/main.qml"));
    
    view.show();

    //MessageHandler::setQmlEngine(view.engine());
    return app.exec();
}
