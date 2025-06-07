import QtQuick
import Quickshell
import Quickshell.Widgets
import "../../widgets" as Widgets
import "../.."

Widgets.IconButton {
  required property var bar;

  id: root;
  implicitSize: 20;
  padding: 2;
  source: "root:/resources/control/controls-button.svg";  
  onClicked: { 
    if (controlLoader.item.visible) {
      controlLoader.item.hide();
    } else {
      controlLoader.item.show(-root.mapFromGlobal(0, 0).x, bar.height);
    }
  }

  LazyLoader {
    id: controlLoader; 
    loading: true;

    ControlPanel {
      id: controlPanel; 
      anchor.window: bar; 
    }
  }
} 

