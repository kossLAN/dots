import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import "../.."

Rectangle {
    required property var notification

    radius: 5;
    color: ShellGlobals.colors.bar;
    border.color: notificationArea.containsMouse 
      ? ShellGlobals.colors.highlight 
      : ShellGlobals.colors.light;
    border.width: 2;
    width: parent.width;
    height: column.implicitHeight + 20; 

    MouseArea {
      id: notificationArea;
      hoverEnabled: true;
      anchors.fill: parent;
    } 

    ColumnLayout {
      id: column;
      spacing: 5;
      
      anchors {
        fill: parent;
        margins: 10;
      }
        
      RowLayout {
        spacing: 5;
        Layout.fillWidth: true;
        
        //IconImage {
        //  visible: notification.appIcon == null;
        //  source: Qt.resolvedUrl(notification.appIcon);
        //  implicitSize: 25;          
        //}

        Text {
          id: summaryText
          text: notification.summary
          color: ShellGlobals.colors.text
          font.pointSize: 14
          font.bold: true
          wrapMode: Text.Wrap;
          Layout.fillWidth: true
          Layout.alignment: Qt.AlignBottom;
        }

        Item {
          width: 16;
          height: 16;
          Layout.alignment: Qt.AlighRight | Qt.AlignTop;
     
          Rectangle {
            color: "#FF474D";
            radius: 5; 
            visible: closeButtonArea.containsMouse;
            anchors.fill: parent; 
          }

          MouseArea {
            id: closeButtonArea; 
            hoverEnabled: true;
            anchors.fill: parent; 
            onPressed: {
              notification.dismiss();
            }
          }

          IconImage {
            source: "image://icon/window-close";
            implicitSize: 28; 
            anchors.centerIn: parent; 
          }
        }
      }

      RowLayout {
        Text {
          id: bodyText
          text: notification.body
          color: ShellGlobals.colors.text
          font.pointSize: 11;
          wrapMode: Text.Wrap
          Layout.fillWidth: true
        }

        //IconImage {
        //  visible: notification.image != null;
        //  source: Qt.resolvedUrl(notification.image);
        //  implicitSize: 25;          
        //}
      
        Layout.fillWidth: true;
      }
    }
}

