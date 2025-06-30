#pragma once
#include <QVector>
#include "BootEntry.h"

class EFIScanner
{
public:
    static QVector<BootEntry> scanAllEFIs();
};
