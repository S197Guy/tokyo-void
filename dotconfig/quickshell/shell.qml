import QtQuick
import QtQuick.Layouts
import Quickshell

ShellRoot {
    PanelWindow {
        anchors {
            top: true
            left: true
            right: true
        }
        height: 32

        Rectangle {
            anchors.fill: parent
            color: "#1a1b26"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 12

                // Workspaces (Placeholder Icons)
                RowLayout {
                    spacing: 8
                    Repeater {
                        model: 5
                        Text {
                            text: ""
                            color: index == 0 ? "#7aa2f7" : "#414868"
                            font.pixelSize: 14
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                // Center Brand
                Text {
                    text: "tokyo-void"
                    color: "#c0caf5"
                    font.bold: true
                    font.pixelSize: 13
                    font.family: "JetBrainsMono Nerd Font"
                    Layout.alignment: Qt.AlignHCenter
                }

                Item { Layout.fillWidth: true }

                // System Info (Simplified Symbols)
                RowLayout {
                    spacing: 12
                    Text {
                        text: "  CPU"
                        color: "#9ece6a"
                        font.pixelSize: 12
                    }
                    Text {
                        text: "  RAM"
                        color: "#bb9af7"
                        font.pixelSize: 12
                    }
                    Text {
                        id: timeText
                        color: "#7dcfff"
                        font.pixelSize: 12
                        font.family: "JetBrainsMono Nerd Font"
                        
                        Timer {
                            interval: 1000; running: true; repeat: true
                            onTriggered: {
                                var now = new Date();
                                timeText.text = " " + now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
                            }
                        }
                        Component.onCompleted: {
                            var now = new Date();
                            text = " " + now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
                        }
                    }
                }
            }
        }
    }
}
