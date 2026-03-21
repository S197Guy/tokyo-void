import QtQuick
import Quickshell
import Quickshell.Wayland

ShellRoot {
    VariantsWindow {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: 30
        
        WlrLayershell.layer: WlrLayershell.Layer.Top
        WlrLayershell.namespace: "quickshell"
        WlrLayershell.anchor: WlrLayershell.Edge.Top | WlrLayershell.Edge.Left | WlrLayershell.Edge.Right

        Rectangle {
            anchors.fill: parent
            color: "#1a1b26"
            border.color: "#414868"
            border.width: 1

            Row {
                anchors.centerIn: parent
                spacing: 20
                
                Text {
                    text: "tokyo-void"
                    color: "#7aa2f7"
                    font.bold: true
                }
                
                Text {
                    text: new Date().toLocaleTimeString()
                    color: "#c0caf5"
                }
            }
        }
    }
}
