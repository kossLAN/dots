import QtQuick
import QtQuick.Layouts
import Quickshell
import "mpris" as Mpris 
import "notifications" as Notifications
import "control" as Control
import ".."

PanelWindow { 
  id: root;
  color: ShellGlobals.colors.window; 
  height: 25

  anchors {
    top: true
    left: true
    right: true
  }

  // Notifications    
  Notifications.Notifications {
    bar: root;
  }
    
  // Widgets - Everything here is sorted where it appears on the bar. 

  // Left 
  RowLayout {
    spacing: 15;

    anchors {
      top: parent.top;
      left: parent.left;
      bottom: parent.bottom;
      leftMargin: 10;
    }

    Workspaces {}

    Separator {
      visible: activeWindow.visible;
    }

    ActiveWindow {
      id: activeWindow;
      Layout.preferredWidth: 250;
    }
  }


  // Middle 

  Mpris.MediaInfo {
    id: mediaInfo;
    bar: root;
    anchors.centerIn: parent;
  }  
  
  // Right
  RowLayout {
    spacing: 15;

    anchors {
      top: parent.top;
      bottom: parent.bottom;
      right: parent.right;
      rightMargin: 10;
    }

    SysTray {
      id: sysTray;
      bar: root;
    }

    Separator {
      visible: sysTray.visible
    }

    BatteryIndicator {
      id: batteryIndicator
    }

    Control.Control {
      bar: root;
    } 

    Separator {} 

    Clock {
      id: clock;
      color: ShellGlobals.colors.text;
    }
  }
}
