#include "MessageHandler.h"

MessageHandler::MessageHandler(QObject *parent) :
    QObject(parent)
{
}

QObject *MessageHandler::m_qmlMessageHandler = nullptr;

void MessageHandler::setQmlEngine(QQmlApplicationEngine *engine)
{
    MessageHandler::m_qmlMessageHandler = engine->rootObjects().first()->findChild<QObject*>("messageHandler");
}

void MessageHandler::setWindow(QQuickWindow *window) {
    MessageHandler::m_qmlMessageHandler = window->findChild<QObject*>("messageHandler");
}

void MessageHandler::handler(QtMsgType messageType, const QMessageLogContext &context, const QString &message)
{
    Q_UNUSED(context)

    // if (messageType == QtFatalMsg)
    //     abort();

    QString messageTypeString;

    switch (messageType) {
    case QtDebugMsg:
        messageTypeString = "Debug";
        break;
    case QtInfoMsg:
        messageTypeString = "Info";
        break;
    case QtWarningMsg:
        messageTypeString = "Warning";
        break;
    case QtCriticalMsg:
        messageTypeString = "Critical";
        break;
    case QtFatalMsg:
        messageTypeString = "Fatal";
        break;
    }

    QString consoleMessageString = QString("%1: %2\n").arg(messageTypeString).arg(message);

    QTextStream textStream(stderr);
    textStream<<consoleMessageString;

    if (m_qmlMessageHandler)
    {
        QString guiMessageString = QString("%1: %2").arg(messageTypeString).arg(message);
        QMetaObject::invokeMethod(m_qmlMessageHandler, "messageReceived", Q_ARG(QString, guiMessageString));
    }
}
