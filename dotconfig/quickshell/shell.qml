import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

ShellRoot {
    PanelWindow {
        id: barWindow
        anchors {
            top: true
            left: true
            right: true
        }
        implicitHeight: 32

        property string battery: "0%"
        property string cpu: "0%"
        property string ram: "0G"
        property string status: "Unknown"
        property var workspaces: []

        Timer {
            interval: 200; running: true; repeat: true; triggeredOnStart: true
            onTriggered: {
                sysInfo.running = true;
                wsInfo.running = true;
            }
        }

        Process {
            id: sysInfo
            command: ["sh", "-c", "if [ -d /sys/class/power_supply/BAT0 ]; then BP=BAT0; elif [ -d /sys/class/power_supply/BAT1 ]; then BP=BAT1; fi; [ -n \"$BP\" ] && cat /sys/class/power_supply/\"$BP\"/capacity || echo 0; [ -n \"$BP\" ] && cat /sys/class/power_supply/\"$BP\"/status || echo Unknown; top -bn1 | grep \"Cpu(s)\" | awk '{for(i=1;i<=NF;i++) if($i==\"id,\") print $(i-1)}' | awk '{print 100 - $1}'; free -h | awk '/Mem:/ {print $3}'"]
            stdout: StdioCollector {
                onStreamFinished: {
                    var lines = text.trim().split("\n");
                    if (lines.length >= 4) {
                        barWindow.battery = lines[0] + "%";
                        barWindow.status = lines[1];
                        barWindow.cpu = lines[2].split(".")[0] + "%";
                        barWindow.ram = lines[3];
                    }
                }
            }
        }

        Process {
            id: wsInfo
            command: ["niri", "msg", "-j", "workspaces"]
            stdout: StdioCollector {
                onStreamFinished: {
                    try {
                        barWindow.workspaces = JSON.parse(text);
                    } catch (e) {}
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
                    font.family: "JetBrainsMono Nerd Font Mono"
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
                        model: barWindow.workspaces
                        Text {
                            text: modelData.is_active ? "\uf192" : "\uf111"
                            color: modelData.is_active ? "#7aa2f7" : "#414868"
                            font.pixelSize: 14
                            font.family: "JetBrainsMono Nerd Font Mono"
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    wsFocus.command = ["niri", "msg", "action", "focus-workspace", modelData.id.toString()];
                                    wsFocus.startDetached();
                                }
                            }
                        }
                    }
                    Process { id: wsFocus }
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: "tokyo-void"
                    color: "#c0caf5"
                    font.bold: true
                    font.pixelSize: 13
                    font.family: "JetBrainsMono Nerd Font Mono"
                    Layout.alignment: Qt.AlignHCenter
                }

                Item { Layout.fillWidth: true }

                RowLayout {
                    spacing: 16
                    Text {
                        text: "\uf2db " + barWindow.cpu
                        color: "#9ece6a"
                        font.pixelSize: 12
                        font.family: "JetBrainsMono Nerd Font Mono"
                    }
                    Text {
                        text: "\uefc5 " + barWindow.ram
                        color: "#bb9af7"
                        font.pixelSize: 12
                        font.family: "JetBrainsMono Nerd Font Mono"
                    }
                    Text {
                        text: (barWindow.status.includes("Charging") ? "\uf0e7 " : "\uf240 ") + barWindow.battery
                        color: parseInt(barWindow.battery) < 20 ? "#f7768e" : "#9ece6a"
                        font.pixelSize: 12
                        font.family: "JetBrainsMono Nerd Font Mono"
                    }
                    Text {
                        id: timeText
                        color: "#7dcfff"
                        font.pixelSize: 12
                        font.family: "JetBrainsMono Nerd Font Mono"
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
                        font.family: "JetBrainsMono Nerd Font Mono"
                        Layout.alignment: Qt.AlignVCenter
                        MouseArea {
                            anchors.fill: parent
                            onClicked: powerMenu.startDetached()
                        }
                        Process {
                            id: powerMenu
                            command: ["/usr/bin/wlogout", "--layout", "/home/neonscar/.config/wlogout/layout", "--css", "/home/neonscar/.config/wlogout/style.css", "--protocol", "layer-shell", "-b", "4"]
                        }
                    }
                }
            }
        }
    }
}
