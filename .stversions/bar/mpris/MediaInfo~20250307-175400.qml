import QtQuick
import Quickshell.Services.Mpris
import Quickshell.Widgets
import "../.."

Item { 
  required property var bar; 

  width: statusInfo.width;
  height: parent.height;

  MediaSwitcher {
    id: mediaSwitcher; 
    anchor.window: bar;
    anchor.rect.x: parentWindow.width / 2 - width / 2;
    anchor.rect.y: parentWindow.height; 
  }

  MouseArea {
    id: playButton; 
    hoverEnabled: true;
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: (mouse)=> {
      if (mouse.button === Qt.LeftButton) {
        if (mediaSwitcher.visible) {
          mediaSwitcher.hide();
        } else {
          mediaSwitcher.show();
        }
        //mediaSwitcher.visible = !mediaSwitcher.visible;
      } else {
        if (!Media.trackedPlayer.canPlay || Media.trackedPlayer == null)
          return; 

        if (Media.trackedPlayer.isPlaying) 
          Media.trackedPlayer.pause();
        else 
          Media.trackedPlayer.play(); 
      } 
    }

    anchors.fill: parent;
  }
  
  Item {
    id: statusInfo;
    width: statusIcon.width + statusIcon.anchors.rightMargin + nowPlayingText.width; 
    visible: Media.trackedPlayer != null; 

    anchors {
      horizontalCenter: parent.horizontalCenter;
      verticalCenter: parent.verticalCenter;
      top: parent.top;
      bottom: parent.botton;
      margins: 3.5; 
    }

    Rectangle {
      color: ShellGlobals.colors.innerHighlight; 
      border.color: ShellGlobals.colors.highlight;
      radius: 3;
      width: parent.width + 25;
      height: parent.height;
      visible: playButton.containsMouse;
      anchors.centerIn: parent;
    }

    IconImage {
      id: statusIcon;
      implicitSize: 13;
      source: Media.trackedPlayer?.isPlaying
        ? "root:resources/mpris/pause.svg" 
        : "root:resources/mpris/play.svg";
    
      anchors {
        verticalCenter: parent.verticalCenter;
        right: nowPlayingText.left;
        rightMargin: 10;
      }
    }

    Text {
      id: nowPlayingText
      color: ShellGlobals.colors.text;
      text: `${Media.trackedPlayer?.trackArtist} - ${Media.trackedPlayer?.trackTitle}`;
      font.pointSize: 11;
      width: Math.min(implicitWidth, 250);
      elide: Text.ElideRight;

      anchors {
        verticalCenter: parent.verticalCenter;
        right: parent.right;
      }
    } 
  }  
}
