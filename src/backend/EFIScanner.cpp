#include "EFIScanner.h"
#include <QDirIterator>
#include <QProcess>
#include <QFileInfo>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QDebug>

QVector<BootEntry> EFIScanner::scanAllEFIs()
{
    QVector<BootEntry> entries;
    const QStringList espPaths = {"/boot/efi/EFI", "/boot/EFI", "/EFI"};

    for (const auto &path : espPaths)
    {
        QDirIterator it(path, QStringList() << "*.efi", QDir::Files, QDirIterator::Subdirectories);
        while (it.hasNext())
        {
            QString fullPath = it.next();
            qDebug() << "[STATIC] Found EFI:" << fullPath;
            entries.append(BootEntry(QFileInfo(fullPath).baseName(), fullPath, "Mounted ESP"));
        }
    }

    QProcess lsblk;
    lsblk.start("lsblk", {"-o", "MOUNTPOINTS,PARTTYPE,PATH", "-J"});
    lsblk.waitForFinished();
    QJsonDocument doc = QJsonDocument::fromJson(lsblk.readAllStandardOutput());
    if (!doc.isObject())
        return entries;

    QJsonArray devices = doc["blockdevices"].toArray();
    for (const auto &dev : devices)
    {
        auto children = dev.toObject()["children"].toArray();
        for (const auto &part : children)
        {
            auto p = part.toObject();
            QString mountpoint = p["mountpoints"].toArray().at(0).toString();
            QString parttype = p["parttype"].toString();

            if (parttype.contains("c12a7328", Qt::CaseInsensitive) && !mountpoint.isEmpty())
            {
                qDebug() << "[LSBLK] Found EFI partition at:" << mountpoint;
                QDirIterator it(mountpoint + "/EFI", QStringList() << "*.efi", QDir::Files, QDirIterator::Subdirectories);
                while (it.hasNext())
                {
                    QString fullPath = it.next();
                    qDebug() << "[LSBLK] Found EFI:" << fullPath;
                    entries.append(BootEntry(QFileInfo(fullPath).baseName(), fullPath, mountpoint));
                }
            }
        }
    }

    return entries;
}
