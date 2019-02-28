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
#include <QQmlApplicationEngine>
#include <QTranslator>
#include <QtGlobal>
#include "MessageHandler.h"
#include "ProjectManager.h"
#include "SyntaxHighlighter.h"

#ifdef Q_OS_ANDROID
#include <QtAndroidExtras/QtAndroid>

bool checkAndroidStoragePermissions() {
    const auto permissionsRequest = QStringList(
    { QString("android.permission.READ_EXTERNAL_STORAGE"),
      QString("android.permission.WRITE_EXTERNAL_STORAGE")});

    if (QtAndroid::checkPermission(permissionsRequest[0])
            == QtAndroid::PermissionResult::Denied
            || (QtAndroid::checkPermission(permissionsRequest[1]))
            == QtAndroid::PermissionResult::Denied) {
        auto permissionResults
                = QtAndroid::requestPermissionsSync(permissionsRequest);
        if ((permissionResults[permissionsRequest[0]]
             == QtAndroid::PermissionResult::Denied)
                || (permissionResults[permissionsRequest[1]]
                    == QtAndroid::PermissionResult::Denied))
            return false;
    }
    return true;
}

#endif

int main(int argc, char *argv[])
{
    qInstallMessageHandler(&MessageHandler::handler);
    QGuiApplication app(argc, argv);
    app.setApplicationName("QML Creator");
    app.setApplicationVersion("1.2.4");
    app.setOrganizationName("wearyinside");
    app.setOrganizationDomain("com.wearyinside.qmlcreator");

    QTranslator translator;
    translator.load("qmlcreator_" + QLocale::system().name(), ":/resources/translations");
    app.installTranslator(&translator);

    qmlRegisterSingletonType<ProjectManager>("ProjectManager", 1, 1, "ProjectManager", &ProjectManager::projectManagerProvider);
    qmlRegisterType<SyntaxHighlighter>("SyntaxHighlighter", 1, 1, "SyntaxHighlighter");

#ifdef Q_OS_ANDROID
    checkAndroidStoragePermissions();
#endif

    QQmlApplicationEngine engine(QUrl("qrc:/qml/main.qml"));

    const QString qtVersion = QT_VERSION_STR;
    const QString buildDateTime = QStringLiteral("%1 %2").arg(__DATE__, __TIME__);
    engine.rootContext()->setContextProperty("qtVersion", qtVersion);
    engine.rootContext()->setContextProperty("buildDateTime", buildDateTime);

    ProjectManager::setQmlEngine(&engine);
    MessageHandler::setQmlEngine(&engine);

    return app.exec();
}
