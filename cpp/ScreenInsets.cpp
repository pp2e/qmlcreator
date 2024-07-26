#include "ScreenInsets.h"


#ifdef Q_OS_IOS
#include <qpa/qplatformwindow.h>
#endif

ScreenInsets::ScreenInsets(QQuickWindow *window)
    : QObject{window}
    , m_window(window)
{}

int ScreenInsets::top() {
#ifdef Q_OS_IOS
    // if window is not ready
    if (m_window == nullptr) return 0;
    QPlatformWindow *pWindow = m_window->handle();
    if (pWindow == nullptr) return 0;
    QMargins margins = pWindow->safeAreaMargins();
    return margins.top();
#else
    return 0;
#endif
}

int ScreenInsets::bottom() {
#ifdef Q_OS_IOS
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
#ifdef Q_OS_IOS
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
#ifdef Q_OS_IOS
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

void ScreenInsets::setWindow(QQuickWindow *window) {
    if (m_window)
        disconnect(m_window, &QWindow::widthChanged,
                   this, &ScreenInsets::insetsChanged);
    m_window = window;
    connect(m_window, &QWindow::widthChanged,
            this, &ScreenInsets::insetsChanged);
    emit insetsChanged();
}
