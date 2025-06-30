#pragma once
#include <QObject>
#include <QString>

class BootHandler : public QObject
{
    Q_OBJECT
public:
    explicit BootHandler(QObject *parent = nullptr);

    Q_INVOKABLE void bootWithEFIBootMgr(const QString &efiPath, const QString &label = "AetherBoot Entry");
    Q_INVOKABLE void bootWithKexec(const QString &kernelPath, const QString &initrdPath, const QString &cmdline);
};