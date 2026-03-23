import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

ShellRoot {
    PanelWindow {
        anchors {
            top: true
            left: true
            right: true
        }
        height: 32

        property string battery: "0%"
        property string cpu: "0%"
        property string ram: "0G"
        property string status: "Unknown"

        Timer {
            interval: 5000; running: true; repeat: true; triggeredOnStart: true
            onTriggered: sysInfo.running = true
        }

        Process {
            id: sysInfo
            // More robust command: auto-detect BAT0/BAT1, use simpler awk
            command: ["sh", "-c", "BP=$(ls -d /sys/class/power_supply/BAT* | head -1); [ -d \"$BP\" ] && cat \"$BP/capacity\" || echo 0; [ -d \"$BP\" ] && cat \"$BP/status\" || echo Unknown; top -bn1 | awk \"/Cpu\\(s\\)/ {print $2}\"; free -h | awk \"/Mem:/ {print $3}\""]
            stdout: StdioCollector {
                onStreamFinished: {
                    var lines = text.trim().split("\n");
                    if (lines.length >= 4) {
                        battery = lines[0] + "%";
                        status = lines[1];
                        cpu = lines[2] + "%";
                        ram = lines[3];
                    }
                }
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
                spacing: 16

                Text {
                    text: "\uf306"
                    color: "#7aa2f7"
                    font.pixelSize: 18
                    font.family: "JetBrainsMono Nerd Font"
                    Layout.alignment: Qt.AlignVCenter
                    MouseArea {
                        anchors.fill: parent
                        onClicked: fuzzelLauncher.startDetached()
                    }
                    Process {
                        id: fuzzelLauncher
                        command: ["/usr/bin/fuzzel"]
                    }
                }

                RowLayout {
                    spacing: 8
                    Repeater {
                        model: 5
                        Text {
                            text: "\uf111"
                            color: index == 0 ? "#7aa2f7" : "#414868"
                            font.pixelSize: 14
                            font.family: "JetBrainsMono Nerd Font"
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: "tokyo-void"
                    color: "#c0caf5"
                    font.bold: true
                    font.pixelSize: 13
                    font.family: "JetBrainsMono Nerd Font"
                    Layout.alignment: Qt.AlignHCenter
                }

                Item { Layout.fillWidth: true }

                RowLayout {
                    spacing: 16
                    Text {
                        text: "\uf2db " + cpu
                        color: "#9ece6a"
                        font.pixelSize: 12
                        font.family: "JetBrainsMono Nerd Font"
                    }
                    Text {
                        text: "\uefc5 " + ram
                        color: "#bb9af7"
                        font.pixelSize: 12
                        font.family: "JetBrainsMono Nerd Font"
                    }
                    Text {
                        text: (status === "Charging" ? "\uf0e7 " : "\uf240 ") + battery
                        color: parseInt(battery) < 20 ? "#f7768e" : "#9ece6a"
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
                                timeText.text = "\uf017 " + now.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
                            }
                        }
                        Component.onCompleted: {
                            var now = new Date();
                            text = "\uf017 " + now.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
                        }
                    }
                    Text {
                        text: "\uf011"
                        color: "#f7768e"
                        font.pixelSize: 16
                        font.family: "JetBrainsMono Nerd Font"
                        Layout.alignment: Qt.AlignVCenter
                        MouseArea {
                            anchors.fill: parent
                            onClicked: powerMenu.startDetached()
                        }
                        Process {
                            id: powerMenu
                            command: ["sh", "-c", "echo -e \"Logout\nReboot\nShutdown\" | fuzzel --dmenu --prompt \"Power: \" | xargs -I{} sh -c \"case {} in Logout) niri msg action quit ;; Reboot) sudo reboot ;; Shutdown) sudo poweroff ;; esac\""]
                        }
                    }
                }
            }
        }
    }
}
