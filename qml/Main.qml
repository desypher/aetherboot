import QtQuick 6.5
import QtQuick.Controls
import QtQuick.Layouts
import Theme 1.0

ApplicationWindow {
    visible: true
    width: 800
    height: 480
    title: "AetherBoot"
    color: Theme.background

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 20

        Text {
            text: "AetherBoot"
            font.pixelSize: Theme.fontSizeTitle
            color: Theme.text
            Layout.alignment: Qt.AlignHCenter
        }

        ListView {
            width: 640
            height: 320
            model: bootEntries
            delegate: Rectangle {
                width: 640
                height: Theme.itemHeight
                color: ListView.isCurrentItem ? Theme.highlight : Theme.surface
                radius: Theme.borderRadius
                border.color: Theme.textSecondary

                RowLayout {
                    anchors.fill: parent
                    spacing: 12

                    Image {
                        source: Theme.osIcons[model.name] || Theme.osIcons["Unknown"]
                        width: 32; height: 32
                        fillMode: Image.PreserveAspectFit
                    }

                    ColumnLayout {
                        Layout.fillWidth: true

                        Text {
                            text: model.name
                            font.pixelSize: Theme.fontSizeName
                            color: Theme.text
                        }
                        Text {
                            text: model.device
                            font.pixelSize: Theme.fontSizeDevice
                            color: Theme.textSecondary
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