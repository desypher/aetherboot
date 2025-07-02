import QtQuick 6.5
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Theme 1.0

ApplicationWindow {
    visible: true
    width: 800
    height: 480
    title: "AetherBoot"
    color: Theme.background

    // Animated background particles
    Canvas {
        id: particleCanvas
        anchors.fill: parent
        opacity: 0.15
        
        property var particles: []
        property int particleCount: 30
        
        Component.onCompleted: {
            for (let i = 0; i < particleCount; i++) {
                particles.push({
                    x: Math.random() * width,
                    y: Math.random() * height,
                    vx: (Math.random() - 0.5) * 0.5,
                    vy: (Math.random() - 0.5) * 0.5,
                    size: Math.random() * 3 + 1
                });
            }
            particleTimer.start();
        }
        
        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            ctx.fillStyle = "#64b5f6";
            
            particles.forEach(function(particle) {
                ctx.beginPath();
                ctx.arc(particle.x, particle.y, particle.size, 0, Math.PI * 2);
                ctx.fill();
            });
        }
        
        Timer {
            id: particleTimer
            interval: 16
            repeat: true
            onTriggered: {
                particleCanvas.particles.forEach(function(particle) {
                    particle.x += particle.vx;
                    particle.y += particle.vy;
                    
                    if (particle.x < 0 || particle.x > particleCanvas.width) particle.vx *= -1;
                    if (particle.y < 0 || particle.y > particleCanvas.height) particle.vy *= -1;
                });
                particleCanvas.requestPaint();
            }
        }
    }

    ColumnLayout {
        id: rootContent
        anchors.centerIn: parent
        spacing: 30

        // Title and Subtitle
        Item {
            Layout.alignment: Qt.AlignHCenter
            width: logoImage.width
            height: logoImage.height + 20

            Image {
                id: logoImage
                source: Theme.logo
                width: 720
                height: 520
                fillMode: Image.PreserveAspectFit
                smooth: true
                Layout.alignment: Qt.AlignHCenter
            } 

            Text {
                id: subtitle
                text: subtitleAnimator.displayText
                font.pixelSize: Theme.fontSizeSubtitle
                color: Theme.textSecondary
                anchors.top: logoImage.bottom
                anchors.topMargin: 8
                anchors.horizontalCenter: logoImage.horizontalCenter

                property string fullText: "Modern UEFI Boot Manager"

                Timer {
                    interval: 100
                    repeat: true
                    running: true
                    onTriggered: {
                        if (subtitleAnimator.currentIndex < subtitle.fullText.length) {
                            subtitleAnimator.displayText += subtitle.fullText[subtitleAnimator.currentIndex];
                            subtitleAnimator.currentIndex++;
                        } else {
                            stop();
                        }
                    }
                }
            }
        }

        QtObject {
            id: subtitleAnimator
            property string displayText: ""
            property int currentIndex: 0
        }

        // Boot list view delegate example
       ListView {
            id: bootListView
            width: 640
            height: 320
            model: bootEntries

            delegate: Item {
                id: delegateItem
                width: bootListView.width
                height: Theme.itemHeight

                transform: [
                    Translate { id: entryTranslate; x: -100 }
                ]

                ParallelAnimation {
                    id: enterAnimation
                    NumberAnimation {
                        target: delegateItem
                        property: "opacity"
                        to: 1
                        duration: 600
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        target: entryTranslate
                        property: "x"
                        to: 0
                        duration: 800
                        easing.type: Easing.OutBack
                    }
                }

                Component.onCompleted: enterAnimation.start()

                Rectangle {
                    anchors.fill: parent
                    radius: Theme.borderRadius
                    color: Theme.surfaceAlt
                    border.color: Theme.border

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: bootListView.currentIndex = index
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        anchors.margins: 12
                        spacing: 16

                        Image {
                            source: Theme.osIcons[model.name] || Theme.osIcons["Unknown"]
                            width: 32
                            height: 32
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            Layout.alignment: Qt.AlignVCenter
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: model.name || "Unknown Entry"
                                font.pixelSize: Theme.fontSizeName
                                color: Theme.text
                            }

                            Text {
                                text: model.device || "Unknown Device"
                                font.pixelSize: Theme.fontSizeDevice
                                color: Theme.textSecondary
                            }
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        startupAnimation.start()
    }

    SequentialAnimation {
        id: startupAnimation
        NumberAnimation {
            target: rootContent
            property: "opacity"
            from: 0
            to: 1
            duration: 1000
            easing.type: Easing.OutCubic
        }
    }
}