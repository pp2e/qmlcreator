qt_add_executable(qmlcreator
    main.cpp
    linenumbershelper.cpp
    linenumbershelper.h
    MessageHandler.cpp
    MessageHandler.h
    ProjectManager.cpp
    ProjectManager.h
    QMLHighlighter.h
    SyntaxHighlighter.cpp
    SyntaxHighlighter.h
    QMLHighlighter.cpp
    QMLHighlighter.h

    # New original code from alteve4d
    ScreenInsets.h
    ScreenInsets.cpp
    windowloader.h
    windowloader.cpp
    modulesfinder.h
    modulesfinder.cpp
)

if (IOS)
    set(app_icons
        ${CMAKE_SOURCE_DIR}/platform-specific/ios/Icon.png
        ${CMAKE_SOURCE_DIR}/platform-specific/ios/Icon@2x.png
        ${CMAKE_SOURCE_DIR}/platform-specific/ios/Icon@3x.png
        ${CMAKE_SOURCE_DIR}/platform-specific/ios/Icon-60.png
        ${CMAKE_SOURCE_DIR}/platform-specific/ios/Icon-60@2x.png
        ${CMAKE_SOURCE_DIR}/platform-specific/ios/Icon-60@3x.png
        ${CMAKE_SOURCE_DIR}/platform-specific/ios/Icon-72.png
        ${CMAKE_SOURCE_DIR}/platform-specific/ios/Icon-72@2x.png
        ${CMAKE_SOURCE_DIR}/platform-specific/ios/Icon-76.png
        ${CMAKE_SOURCE_DIR}/platform-specific/ios/Icon-76@2x.png
    )
    target_sources(qmlcreator PRIVATE ${app_icons})
    set_source_files_properties(${app_icons} PROPERTIES
        MACOSX_PACKAGE_LOCATION Resources
    )
    set_target_properties(
        qmlcreator
        PROPERTIES
        MACOSX_BUNDLE TRUE
        MACOSX_BUNDLE_INFO_PLIST ${CMAKE_SOURCE_DIR}/platform-specific/ios/Info.plist
    )
    target_link_libraries(qmlcreator PRIVATE Qt6::GuiPrivate)
endif()

qt_add_qml_module(qmlcreator
    URI QmlCreator

    RESOURCES
    resources/dictionaries/javascript.txt
    resources/dictionaries/keywords.txt
    resources/dictionaries/properties.txt
    resources/dictionaries/qml.txt
    resources/fonts/editor/DejaVu\ Font\ License.txt
    resources/fonts/editor/Droid\ Font\ License.txt
    resources/fonts/editor/Fira\ Font\ License.txt
    resources/fonts/editor/Liberation\ Font\ License.txt
    resources/fonts/editor/Source\ Code\ Font\ License.txt
    resources/fonts/editor/Ubuntu\ Font\ License.txt
    resources/fonts/editor/dejavusansmono.ttf
    resources/fonts/editor/droidsansmono.ttf
    resources/fonts/editor/firamono.ttf
    resources/fonts/editor/liberationmono.ttf
    resources/fonts/editor/sourcecodepro.ttf
    resources/fonts/editor/ubuntumono.ttf
    resources/fonts/ui/Font\ Awesome\ License.txt
    resources/fonts/ui/Roboto\ Font\ License.txt
    resources/fonts/ui/fontawesome.ttf
    resources/fonts/ui/robotobold.ttf
    resources/fonts/ui/robotobolditalic.ttf
    resources/fonts/ui/robotoitalic.ttf
    resources/fonts/ui/robotoregular.ttf
    resources/images/file.svg
    resources/images/folder.svg
    resources/images/icon128.png
    resources/images/icon256.png
    resources/images/icon512.png
    resources/images/particle1.png
    resources/images/particle2.png
    resources/meshes/logo.obj
    resources/templates/JsFile.js
    resources/templates/MainFile.qml
    resources/templates/QmlFile.qml
    resources/translations/qmlcreator_fr.ts
    resources/translations/qmlcreator_ru.qm
    resources/translations/qmlcreator_ru.ts

    examples/3D/main.qml
    examples/Accelerometer/main.qml
    examples/Ambient\ Light\ Sensor/main.qml
    examples/Analog\ Clock/Clock.qml
    examples/Analog\ Clock/ClockBackground.qml
    examples/Analog\ Clock/ClockDigits.qml
    examples/Analog\ Clock/ClockHand.qml
    examples/Analog\ Clock/main.qml
    examples/Camera/main.qml
    examples/Canvas/main.qml
    examples/Controls/main.qml
    examples/Debugging/Rect.qml
    examples/Debugging/main.qml
    examples/Device\ Info/main.qml
    examples/Dialogs/ColorDialogTab.qml
    examples/Dialogs/MessageDialogTab.qml
    examples/Dialogs/main.qml
    examples/Gradient\ Text/main.qml
    examples/Graphical\ Effects/BrightnessContrastTab.qml
    examples/Graphical\ Effects/DesaturateTab.qml
    examples/Graphical\ Effects/DirectionalBlurTab.qml
    examples/Graphical\ Effects/main.qml
    examples/Joystick/Joystick.qml
    examples/Joystick/Player.qml
    examples/Joystick/main.qml
    examples/Live\ Webcam/WebcamsModel.qml
    examples/Live\ Webcam/main.qml
    examples/Local\ Storage/Database.js
    examples/Local\ Storage/main.qml
    examples/Looped\ List\ View/DateSelector.qml
    examples/Looped\ List\ View/LoopedListView.qml
    examples/Looped\ List\ View/LoopedListViewDelegate.qml
    examples/Looped\ List\ View/NumberSelector.qml
    examples/Looped\ List\ View/main.qml
    examples/Map/main.qml
    examples/Multi-touch/TouchItem.qml
    examples/Multi-touch/main.qml
    examples/Particles/main.qml
    examples/Proximity\ Sensor/main.qml
    examples/Repeater/ColorRect.qml
    examples/Repeater/main.qml
    examples/Settings/main.qml
    examples/Shader\ Effect/main.qml
    examples/Styles/SBusyIndicatorStyle.qml
    examples/Styles/SButtonStyle.qml
    examples/Styles/main.qml
    examples/Swipe\ View/LogInScreen.qml
    examples/Swipe\ View/RegisterScreen.qml
    examples/Swipe\ View/RestorePasswordScreen.qml
    examples/Swipe\ View/SwipeScreen.qml
    examples/Swipe\ View/SwipeView.qml
    examples/Swipe\ View/main.qml
    examples/Timer/main.qml
    examples/Torch/main.qml
    examples/Transform/main.qml
    examples/WebSocket/main.qml
    examples/XMLHttpRequest/main.qml

    QML_FILES
    qml/components/dialogs/BaseDialog.qml
    qml/components/dialogs/ConfirmationDialog.qml
    qml/components/dialogs/DialogLoader.qml
    qml/components/dialogs/FontFamilyDialog.qml
    qml/components/dialogs/FontSizeDialog.qml
    qml/components/dialogs/IndentSizeDialog.qml
    qml/components/dialogs/ListDialog.qml
    qml/components/dialogs/MessageDialog.qml
    qml/components/dialogs/NewDirDialog.qml
    qml/components/dialogs/NewFileDialog.qml
    qml/components/dialogs/NewProjectDialog.qml
    qml/components/palettes/BasePalette.qml
    qml/components/palettes/CutePalette.qml
    qml/components/palettes/DarkPalette.qml
    qml/components/palettes/LightPalette.qml
    qml/components/palettes/PaletteLoader.qml
    qml/components/CBackButton.qml
    qml/components/CCheckBox.qml
    qml/components/CContextMenuButton.qml
    qml/components/CDialogButton.qml
    qml/components/CEditorScrollBar.qml
    qml/components/CFileButton.qml
    qml/components/CFlickable.qml
    qml/components/CHorizontalSeparator.qml
    qml/components/CIcon.qml
    qml/components/CLabel.qml
    qml/components/CListView.qml
    qml/components/CNavigationButton.qml
    qml/components/CScrollBar.qml
    qml/components/CSettingButton.qml
    qml/components/CSlider.qml
    qml/components/CSplitView.qml
    qml/components/CSwitcher.qml
    qml/components/CTextArea.qml
    qml/components/CToolButton.qml
    qml/components/CTooltip.qml
    qml/components/CVerticalSeparator.qml
    qml/components/CApplicationWindow.qml
    qml/components/CToolBarBlur.qml
    qml/components/CToolBar.qml
    qml/components/CNavigationScrollBar.qml
    qml/components/CCodeArea.qml
    qml/components/CInformationItem.qml
    qml/components/CTextField.qml
    qml/screens/BlankScreen.qml
    qml/screens/AboutScreen.qml
    qml/screens/EditorScreen.qml
    qml/screens/FilesScreen.qml
    qml/screens/SettingsScreen.qml
    qml/screens/PlaygroundScreen.qml
    qml/screens/ModulesScreen.qml
    qml/main.qml

    QML_FILES
    # New original qml code from altevedev
    qml/screens/NewPlaygroundScreen.qml
)

target_link_libraries(qmlcreator PRIVATE Qt6::Quick)
