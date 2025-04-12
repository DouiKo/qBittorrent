#ifndef MACSTATUSITEM_H
#define MACSTATUSITEM_H

#include <QObject>
#include <QString>

class MacStatus : public QObject {
    Q_OBJECT
public:
    explicit MacStatus(QObject *parent = nullptr);
    ~MacStatus();

    void initialize();
    void updateSpeedText(const QString &text);

    static void showAppDock();
    static void hideAppDock();

signals:
    void showMainWindowRequested();

private:
    void createStatusItem();
    void createContextMenu();
};

#endif
