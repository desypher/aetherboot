import QtQuick 6.5
import QtQuick.Controls
import QtQuick.Layouts
import "." as Theme

ApplicationWindow {
    visible: true
    width: 800
    height: 480
    title: "AetherBoot"
    color: Theme.Theme.background

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 20

        Text {
            text: "AetherBoot"
            font.pixelSize: Theme.Theme.fontSizeTitle
            color: Theme.Theme.text
            Layout.alignment: Qt.AlignHCenter
        }

        ListView {
            width: 640
            height: 320
            model: bootEntries
            delegate: Rectangle {
                width: 640
                height: Theme.Theme.itemHeight
                color: ListView.isCurrentItem ? Theme.Theme.highlight : Theme.Theme.surface
                radius: Theme.Theme.borderRadius
                border.color: Theme.Theme.textSecondary

                RowLayout {
                    anchors.fill: parent
                    spacing: 12
                    padding: 8

                    Image {
                        source: Theme.Theme.osIcons[model.name] || Theme.Theme.osIcons["Unknown"]
                        width: 32; height: 32
                        fillMode: Image.PreserveAspectFit
                        color: Theme.Theme.text   // <-- tint the SVG icon white
                    }

                    ColumnLayout {
                        Layout.fillWidth: true

                        Text {
                            text: model.name
                            font.pixelSize: Theme.Theme.fontSizeName
                            color: Theme.Theme.text
                        }
                        Text {
                            text: model.device
                            font.pixelSize: Theme.Theme.fontSizeDevice
                            color: Theme.Theme.textSecondary
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        console.log("Selected:", model.path)
                        bootHandler.boot(model.path)
                    }
                }
            }
            focus: true
            Keys.onReturnPressed: {
                console.log("Booting:", model.path)
                bootHandler.boot(model.path)
            }
        }
    }
}