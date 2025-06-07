import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell.Widgets 
import "../.."

Item { 
  property string source; 
  property string text: ""; 
  property string subText: "";
  property real implicitSize; // icon implicit size 
  property real padding: 0; 
  property real radius: 5;
  signal clicked();

  id: root; 
  width: implicitSize*3;
  height: implicitSize*1.25;

  Rectangle {
    id: iconBackground;
    color: iconButton.containsMouse 
      ? ShellGlobals.colors.innerHighlight 
      : ShellGlobals.colors.midlight;
    border.color: iconButton.containsMouse 
      ? ShellGlobals.colors.highlight 
      : ShellGlobals.colors.light; 
    radius: root.radius;  
    anchors.fill: parent;

    RowLayout {
      spacing: 5; 
      
      anchors {
        fill: parent; 
        margins: root.padding;
      }

      IconImage {
        id: iconImage;
        implicitSize: root.implicitSize;
        source: root.source; 
      }

      ColumnLayout {
        id: textLayout;
        spacing: 3;
        Layout.fillWidth: true;

        Text {
          text: root.text;
          color: ShellGlobals.colors.text;
          font.pointSize: 11;
          font.bold: true;
          visible: text.length > 0;
        }

        Text {
          text: root.subText;
          color: ShellGlobals.colors.text;
          font.pointSize: 10; 
          visible: text.length > 0;
        }
      }
    }

    MouseArea {
      id: iconButton; 
      hoverEnabled: true;
      anchors.fill: parent;
      onPressed: root.clicked(); 
    }
  }  
} 
