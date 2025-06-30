#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "backend/EFIScanner.h"
#include "BootHandler.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    // Get boot entries
    const auto entries = EFIScanner::scanAllEFIs();
    QVariantList bootEntries;
    for (const auto &entry : entries)
    {
        QVariantMap item;
        item["name"] = entry.name;
        item["path"] = entry.path;
        item["device"] = entry.device;
        bootEntries << item;
    }

    engine.rootContext()->setContextProperty("bootEntries", bootEntries);
    engine.rootContext()->setContextProperty("bootHandler", new BootHandler());
    engine.load(QUrl(QStringLiteral("qrc:/qml/Main.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;
    return app.exec();
}