import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

ShellRoot {
    VariantsWindow {
        WlrLayershell.layer: WlrLayershell.Layer.Top
        WlrLayershell.namespace: "quickshell"
        WlrLayershell.edges: WlrLayershell.Edge.Top | WlrLayershell.Edge.Left | WlrLayershell.Edge.Right
        
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
                    Layout.alignment: Qt.AlignVCenter
                }

                Item { Layout.fillWidth: true }
                
                Text {
                    id: timeText
                    property var time: new Date()
                    text: time.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
                    color: "#c0caf5"
                    Layout.alignment: Qt.AlignVCenter
                    
                    Timer {
                        interval: 1000; running: true; repeat: true
                        onTriggered: timeText.time = new Date()
                    }
                }
            }
        }
    }
}
