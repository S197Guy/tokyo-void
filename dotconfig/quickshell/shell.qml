import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

ShellRoot {
    PanelWindow {
        anchors.top: true
        anchors.left: true
        anchors.right: true
        height: 32

        property string batteryPath: "/sys/class/power_supply/BAT0"
        property string percentage: "0"
        property string status: "Unknown"

        Timer {
            interval: 30000; running: true; repeat: true; triggeredOnStart: true
            onTriggered: {
                readCapacity.start()
                readStatus.start()
            }
        }

        Process {
            id: readCapacity
            command: ["cat", batteryPath + "/capacity"]
            stdout: StdioCollector {
                onLineRead: (line) => percentage = line.trim()
            }
        }

        Process {
            id: readStatus
            command: ["cat", batteryPath + "/status"]
            stdout: StdioCollector {
                onLineRead: (line) => status = line.trim()
            }
        }

        Rectangle {
            anchors.fill: parent
            color: "#1a1b26"
            border.color: "#414868"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 12

                // Launcher Button
                Text {
                    text: "󱓟"
                    color: "#7aa2f7"
                    font.pixelSize: 18
                    Layout.alignment: Qt.AlignVCenter
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            fuzzelProcess.start()
                        }
                    }
                    
                    Process {
                        id: fuzzelProcess
                        command: ["/usr/bin/fuzzel"]
                    }
                }

                // Workspaces
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

                Text {
                    text: "tokyo-void"
                    color: "#c0caf5"
                    font.bold: true
                    font.pixelSize: 13
                    Layout.alignment: Qt.AlignHCenter
                }

                Item { Layout.fillWidth: true }

                // Status Info
                RowLayout {
                    spacing: 16
                    
                    // Battery
                    Text {
                        text: (status === "Charging" ? "󱐋 " : "󰁹 ") + percentage + "%"
                        color: percentage < 20 ? "#f7768e" : "#9ece6a"
                        font.pixelSize: 12
                        font.family: "JetBrainsMono Nerd Font"
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
                                timeText.text = " " + now.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
                            }
                        }
                        Component.onCompleted: {
                            var now = new Date();
                            text = " " + now.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
                        }
                    }
                }
            }
        }
    }
}
