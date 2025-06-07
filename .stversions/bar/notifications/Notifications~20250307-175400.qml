import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import ".."

Scope {
  required property var bar;

  NotificationServer {
    id: notificationServer;
    actionsSupported: true;
    persistenceSupported: true;
  }

  Connections {
    target: notificationServer;

    function onNotification(notification) {
      notificationLoader.item.visible = true;
      notification.tracked = true;
    }
  }

  LazyLoader {
    id: notificationLoader;
    loading: true;

    PanelWindow  { 
      id: notificationWindow;
      color: "transparent";
      width: 500;
      visible: false;
      exclusionMode: ExclusionMode.Normal;
      mask: Region { item: notifLayout; } 

      anchors {
        top: true;
        bottom: true;
        right: true;
      }

      margins {
        top: 5;
        bottom: 5;
        right: 5;
      } 
          
      ColumnLayout { 
        id: notifLayout;
        spacing: 15;

        anchors { 
          top: parent.top;
          left: parent.left;
          right: parent.right;
          margins: 5;
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
  }
}
