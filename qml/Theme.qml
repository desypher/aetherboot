pragma Singleton
import QtQuick 6.5

QtObject {
    // Colors
    property color background: "#0e0e0e"
    property color surface: "#1a1a1a"
    property color surfaceAlt: "#1e1e2e"
    property color highlight: "#3a86ff"
    property color text: "#ffffff"
    property color textSecondary: "#bbbbbb"
    property color border: "#3a3a4e"

    // Font sizes
    property int fontSizeTitle: 48
    property int fontSizeName: 18
    property int fontSizeDevice: 12
    property int fontSizeSubtitle: 16

    // Layout
    property int borderRadius: 12
    property int itemHeight: 60

    // OS icons
    property var osIcons: {
        "Windows": "qrc:qml/icons/windows.png",
        "Linux": "qrc:qml/icons/linux.png",
        "Arch": "qrc:qml/icons/arch.png",
        "Ubuntu": "qrc:qml/icons/ubuntu.png",
        "Fedora": "qrc:qml/icons/fedora.png",
        "Debian": "qrc:qml/icons/debian.png",
        "Unknown": "qrc:qml/icons/efi.png"
    }

    // Logo
    property string logo: "qrc:qml/icons/aetherboot.png"
}