import QtQuick 6.5
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    visible: true
    width: 800
    height: 480
    title: "AetherBoot"
    color: "#101010"

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 20

        Text {
            text: "AetherBoot"
            font.pixelSize: 32
            color: "white"
            Layout.alignment: Qt.AlignHCenter
        }

        ListView {
            width: 600
            height: 300
            model: bootEntries
            delegate: Rectangle {
                width: 600
                height: 50
                color: ListView.isCurrentItem ? "#444" : "#222"
                border.color: "#888"
                radius: 8

                Column {
                    anchors.centerIn: parent
                    spacing: 2
                    Text { text: model.name; color: "white"; font.pixelSize: 18 }
                    Text { text: model.device; color: "#aaa"; font.pixelSize: 12 }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        console.log("Selected:", model.path)
                        // TODO: trigger EFI launch here
                    }
                }
            }
            focus: true
            Keys.onReturnPressed: {
                console.log("Booting:", model.path)
                // TODO: integrate boot handler
            }
        }
    }
}
