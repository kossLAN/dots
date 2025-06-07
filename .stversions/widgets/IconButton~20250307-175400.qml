import QtQuick
import QtQuick.Effects
import Quickshell.Widgets 
import ".."

Item { 
  property string source; 
  property var implicitSize; 
  property var padding: 0; 
  property var radius: 5;
  signal clicked();

  id: root; 
  implicitWidth: implicitSize;
  implicitHeight: implicitSize;

  Rectangle {
    id: iconBackground;
    color: ShellGlobals.colors.innerHighlight;
    border.color: ShellGlobals.colors.highlight; 
    radius: root.radius; 
    visible: iconButton.containsMouse;
    anchors.fill: parent;
  }

  IconImage {
    id: iconImage; 
    source: root.source;

    anchors {
      fill: parent;
      margins: padding;
    }
  }

  MouseArea {
    id: iconButton; 
    hoverEnabled: true;
    anchors.fill: parent;
    onPressed: root.clicked(); 
  }
} 
