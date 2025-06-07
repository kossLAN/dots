import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import "../../widgets" as Widgets
import "../.."

PopupWindow {  
  id: root;
  width: controlContainer.implicitWidth+25
  height: controlContainer.implicitHeight+25
  //width: 275;
  //height: 400;
  color: "transparent"
  visible: controlContainer.opacity > 0;   

  function show(x, y) { 
    root.anchor.rect.x = x;
    root.anchor.rect.y = y;
    controlContainer.opacity = 1;
  }

  function hide() {
    controlContainer.opacity = 0;
  }

  HoverHandler {
    id: hoverHandler; 
    enabled: true;
    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad;
    onHoveredChanged: {
      if (hovered === false) {
        hide(); 
      }
    }
  }

  Rectangle {
    id: controlContainer; 
    color: ShellGlobals.colors.window;
    radius: 5;
    opacity: 0; // TODO: change to 0
    layer.enabled: true;
    layer.effect: DropShadow {
      transparentBorder: true; 
      spread: 0.02;
      samples: 25; 
      color: "#80000000";
    }

    implicitWidth: columnLayout.implicitWidth + 20 // Add margins
    implicitHeight: columnLayout.implicitHeight + 20 // Add margins

    anchors {
      centerIn: parent;
      margins: 5;
    }

    Behavior on opacity {
      NumberAnimation {
        duration: 300;
        easing.type: Easing.OutCubic;
      }
    }   

    ColumnLayout {
      id: columnLayout
      spacing: 10; 

      anchors {
        left: parent.left
        right: parent.right
        top: parent.top
        bottom: parent.bottom
        margins: 10 // Padding from the parent rectangle
      }

      RowLayout {
        spacing: 10;

        Rectangle {
          width: 120;
          height: 120;
        }

        Rectangle {
          width: 120;
          height: 120;
        }
      }
    }
  }
}

