#include "BootHandler.h"
#include <QProcess>
#include <QDebug>

void BootHandler::bootWithEFIBootMgr(const QString &efiPath)
{
    QString bootNum = "0007"; // Custom boot entry ID
    QString label = "AetherBoot Custom";

    QProcess::execute("efibootmgr", {"-c", "-d", "/dev/sda", "-p", "1", // adjust for correct ESP
                                     "-L", label,
                                     "-l", efiPath});

    QProcess::execute("efibootmgr", {"-n", bootNum}); // one-time boot
    QProcess::execute("reboot");
}

void BootHandler::bootWithKexec(const QString &kernelPath, const QString &initrdPath, const QString &cmdline)
{
    QProcess::execute("kexec", {"-l", kernelPath,
                                "--initrd=" + initrdPath,
                                "--command-line=" + cmdline});

    QProcess::execute("kexec", {"-e"}); // execute
}