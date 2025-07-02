#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "backend/EFIScanner.h"
#include "BootHandler.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    // Register Theme singleton
    qmlRegisterSingletonType(QUrl(QStringLiteral("qrc:/qml/Theme.qml")),
                             "Theme", 1, 0, "Theme");

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

    // Register context properties
    engine.rootContext()->setContextProperty("bootEntries", bootEntries);

    // Create BootHandler with app as parent (or nullptr)
    BootHandler *bootHandler = new BootHandler(&app);
    engine.rootContext()->setContextProperty("bootHandler", bootHandler);

    engine.load(QUrl(QStringLiteral("qrc:/qml/Main.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}