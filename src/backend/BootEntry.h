#pragma once
#include <QString>

class BootEntry
{
public:
    QString name;
    QString path;
    QString device;

    BootEntry(const QString &name, const QString &path, const QString &device)
        : name(name), path(path), device(device) {}
};
