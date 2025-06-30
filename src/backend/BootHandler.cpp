#include "BootHandler.h"
#include <QProcess>
#include <QDebug>

#include "BootHandler.h"

BootHandler::BootHandler(QObject *parent) : QObject(parent)
{
    // You can leave this empty or add initialization code here
}

void BootHandler::bootWithEFIBootMgr(const QString &efiPath, const QString &label)
{
    qDebug() << "Booting with efibootmgr:" << efiPath;
    QProcess::execute("efibootmgr", {"-c", "-d", "/dev/sda", "-p", "1",
                                     "-L", label,
                                     "-l", efiPath});
    QProcess::execute("reboot");
}

void BootHandler::bootWithKexec(const QString &kernelPath, const QString &initrdPath, const QString &cmdline)
{
    qDebug() << "Booting with kexec:" << kernelPath;
    QProcess::execute("kexec", {"-l", kernelPath,
                                "--initrd=" + initrdPath,
                                "--command-line=" + cmdline});
    QProcess::execute("kexec", {"-e"});
}
