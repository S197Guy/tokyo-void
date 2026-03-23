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
            border.color: "#414868"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                spacing: 20
                
                Text {
                    text: "tokyo-void"
                    color: "#7aa2f7"
                    font.bold: true
                    font.pixelSize: 14
                    Layout.alignment: Qt.AlignVCenter
                }

                Item { Layout.fillWidth: true }
                
                Text {
                    id: timeText
                    color: "#c0caf5"
                    font.pixelSize: 14
                    Layout.alignment: Qt.AlignVCenter
                    
                    Timer {
                        interval: 1000; running: true; repeat: true
                        onTriggered: {
                            var now = new Date();
                            timeText.text = now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
                        }
                    }
                    
                    Component.onCompleted: {
                        var now = new Date();
                        text = now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
                    }
                }
            }
        }
    }
}
