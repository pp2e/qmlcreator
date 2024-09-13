QML Creator - Kirigami
=========

Kirigami ui is not usable now because clearComponentCache method used to reload components breaks it. Function trimComponentCache which does not break it dont work (I reported it as [QTBUG-128821](https://bugreports.qt.io/browse/QTBUG-128821). Cache clearing is disabled to demonstrate ui.
