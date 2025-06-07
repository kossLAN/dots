import QtQuick 
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import "../widgets" as Widgets 
import ".."

RowLayout { 
  required property var bar;

  spacing: 10;
  visible: SystemTray.items.values.length > 0

  Repeater {
    model: SystemTray.items;

    Widgets.IconButton {
      id: iconButton;
      implicitSize: 20;
      source: modelData.icon;

      onClicked: modelData.display(bar, -parent.mapFromGlobal(0, 0).x, root.height+5);         
    }
    
  }  
}
