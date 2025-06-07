import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import ".."

PanelWindow {
  required property var bar;

  id: notificationWindow;
  color: "transparent";
  width: 550; 
  height: 600;
  visible: true;
  mask: Region { item: notifLayout; } 

  anchors {
    top: true;
    bottom: true;
  }

  margins {
		top: 5;
    bottom: 5;
		right: 5;
  }


  NotificationServer {
    id: notificationServer;
    actionsSupported: true;
    persistenceSupported: true;
  }

  Connections {
    target: notificationServer;

    function onNotification(notification) {
      notification.tracked = true;
    }
  }
  
  ColumnLayout { 
    id: notifLayout;
    spacing: 5;

    anchors { 
      left: parent.left;
      right: parent.right;
    }

    Repeater {
      model: notificationServer.trackedNotifications;

      Toast {
        required property var modelData;
        notification: modelData;
      }
    }
  }
}
