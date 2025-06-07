import QtQuick
import Quickshell.Hyprland
import ".."

Text {
  id: windowText;
  text: "";
  color: ShellGlobals.colors.text;
  font.pointSize: 11;
  visible: text !== "";  
  elide: Text.ElideRight;

  Connections {
    target: Hyprland;
    
    function onRawEvent(event) {
      if (event.name === "activewindow") { 
        windowText.text = event.parse(2)[1]; 
      }
    }
  } 
}
