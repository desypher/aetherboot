#pragma once
#include <QString>

class BootHandler
{
public:
    static void bootWithEFIBootMgr(const QString &efiPath);
    static void bootWithKexec(const QString &kernelPath, const QString &initrdPath, const QString &cmdline);
};