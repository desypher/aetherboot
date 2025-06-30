pragma Singleton
import QtQuick 6.5

QtObject {
    property color background: "#0e0e0e"
    property color surface: "#1a1a1a"
    property color highlight: "#3a86ff"
    property color text: "#ffffff"
    property color textSecondary: "#bbbbbb"

    property int fontSizeTitle: 32
    property int fontSizeName: 18
    property int fontSizeDevice: 12

    property int borderRadius: 8
    property int itemHeight: 56

    property var osIcons: {
        "Windows": "qrc:/icons/windows.svg",
        "Linux": "qrc:/icons/linux.svg",
        "Arch": "qrc:/icons/arch.svg",
        "Ubuntu": "qrc:/icons/ubuntu.svg",
        "Fedora": "qrc:/icons/fedora.svg",
        "Debian": "qrc:/icons/debian.svg",
        "Unknown": "qrc:/icons/efi.svg"
    }
}
