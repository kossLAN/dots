import QtQuick
import Quickshell.Hyprland
import ".."

Rectangle {
  width: 200;
  height: parent.height; 
  color: "black"

  Text {
    id: windowText;
    text: "";
    color: ShellGlobals.colors.text;
    font.pointSize: 11;
    visible: text !== "";  
    elide: Text.ElideRight;

    anchors {
      left: parent.left 
      //right: parent.right; 
      verticalCenter: verticalCenter.parent;
    }

    Connections {
      target: Hyprland;
      
      function onRawEvent(event) {
        if (event.name === "activewindow") { 
          windowText.text = event.parse(2)[1]; 
        }
      }
    }
  }
}
