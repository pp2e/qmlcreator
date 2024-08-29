#include "ScreenInsets.h"


#if defined(Q_OS_IOS)
#include <qpa/qplatformwindow.h>
#elif defined(Q_OS_ANDROID)
#include <QJniObject>
#endif

ScreenInsets::ScreenInsets(QQuickWindow *window)
    : QObject{window}
    , m_window(window)
{}

int ScreenInsets::top() {
#if defined(Q_OS_IOS)
    // if window is not ready
    if (m_window == nullptr) return 0;
    QPlatformWindow *pWindow = m_window->handle();
    if (pWindow == nullptr) return 0;
    QMargins margins = pWindow->safeAreaMargins();
    return margins.top();
#elif defined(Q_OS_ANDROID)
    // thanks
    // https://bugfreeblog.duckdns.org/2023/01/qt-qml-cutouts.html
    QJniObject activity = QNativeInterface::QAndroidApplication::context();

    QJniObject window = activity.callObjectMethod("getWindow", "()Landroid/view/Window;");
    QJniObject decorView = window.callObjectMethod("getDecorView", "()Landroid/view/View;");
    QJniObject insets = decorView.callObjectMethod("getRootWindowInsets", "()Landroid/view/WindowInsets;");
    return insets.callMethod<int>("getSystemWindowInsetTop", "()I")/qApp->devicePixelRatio(); // deprecated but who cares hehe
#else
    return 0;
#endif
}

int ScreenInsets::bottom() {
#if defined(Q_OS_IOS)
    // if window is not ready
    if (m_window == nullptr) return 0;
    QPlatformWindow *pWindow = m_window->handle();
    if (pWindow == nullptr) return 0;
    QMargins margins = pWindow->safeAreaMargins();
    return margins.bottom();
#else
    return 0;
#endif
}

int ScreenInsets::left() {
#if defined(Q_OS_IOS)
    // if window is not ready
    if (m_window == nullptr) return 0;
    QPlatformWindow *pWindow = m_window->handle();
    if (pWindow == nullptr) return 0;
    QMargins margins = pWindow->safeAreaMargins();
    return margins.left();
#else
    return 0;
#endif
}

int ScreenInsets::right() {
#if defined(Q_OS_IOS)
    // if window is not ready
    if (m_window == nullptr) return 0;
    QPlatformWindow *pWindow = m_window->handle();
    if (pWindow == nullptr) return 0;
    QMargins margins = pWindow->safeAreaMargins();
    return margins.right();
#else
    return 0;
#endif
}

QQuickWindow *ScreenInsets::window() {
    return m_window;
}

void ScreenInsets::setWindow(QQuickWindow *window) {
    if (m_window)
        disconnect(m_window, &QWindow::widthChanged,
                   this, &ScreenInsets::insetsChanged);
    m_window = window;
    connect(m_window, &QWindow::widthChanged,
            this, &ScreenInsets::insetsChanged);
    emit insetsChanged();
}
