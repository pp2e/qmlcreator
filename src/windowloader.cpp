#include "windowloader.h"

#include <QQuickItem>

WindowLoader::WindowLoader(QObject *parent)
    : QObject{parent} {}

WindowLoader::~WindowLoader() {
    if (!m_window) return;

    m_window->hide();
    m_window->deleteLater();
}

QString WindowLoader::source() const {
    return m_source;
}

void WindowLoader::setSource(const QString &source) {
    if (m_source == source) return;

    load(source);
}

void WindowLoader::load(const QString &source, QVariantMap properties) {
    m_source = source;
    m_properties = properties;
    if (m_hideWindow) {
        // If component is window we need to hide it, if not we will undo that later
        m_properties.insert("visible", false);
    }
    emit sourceChanged();

    if (m_window) {
        m_window->hide();
        m_window->deleteLater();
        m_window = nullptr; // for safety
    }

    // if we want to clear window
    if (m_source == "") {
        emit windowChanged();
        return;
    }

    m_engine.clearComponentCache();
    QQmlComponent *component = new QQmlComponent(&m_engine, QUrl(m_source), &m_engine);
    if (component->isLoading())
        QObject::connect(component, &QQmlComponent::statusChanged,
                         [=] () {createWindow(component);});
    else
        createWindow(component);
}

QColor WindowLoader::color() const {
    return m_color;
}

void WindowLoader::setColor(const QColor color) {
    if (m_color == color) return;

    m_color = color;
    emit colorChanged();
}

QQuickWindow *WindowLoader::window() const {
    return m_window;
}

bool WindowLoader::hideWindow() {
    return m_hideWindow;
}

void WindowLoader::setHideWindow(bool hideWindow) {
    if (m_hideWindow == hideWindow) return;
    
    m_hideWindow = hideWindow;
    emit hideWindowChanged();
}

QQmlEngine *WindowLoader::engine() {
    return &m_engine;
}

void WindowLoader::createWindow(QQmlComponent *component) {
    if (component->status() == QQmlComponent::Error) {
        emit error(component->errorString());
        delete component;
        // m_window = nullptr; // It already done
        emit windowChanged();
        return;
    }

    QObject *object = component->createWithInitialProperties(m_properties);
    delete component;

    m_window = qobject_cast<QQuickWindow*>(object);

    // if root item is not window
    if (!m_window) {
        QQuickItem *item = qobject_cast<QQuickItem*>(object);
        if (!item) {
            m_window = nullptr;
            emit windowChanged();
        }
        if (m_hideWindow) item->setVisible(true);
        m_window = new QQuickWindow();
        item->setParentItem(m_window->contentItem());
        m_window->setColor(m_color);
    }

    emit windowChanged();
}
