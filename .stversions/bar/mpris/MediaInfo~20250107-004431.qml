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
  }

  MouseArea {
    id: playButton; 
    hoverEnabled: true;
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: (mouse)=> {
      if (mouse.button === Qt.LeftButton) {
        mediaSwitcher.visible = !mediaSwitcher.visible;
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
      radius: 5;
      width: parent.width + 25;
      height: parent.height;
      visible: playButton.containsMouse;
      anchors.centerIn: parent;
    }

    IconImage {
      id: statusIcon;
      implicitSize: 13;
      source: Media.trackedPlayer?.isPlaying
        ? Qt.resolvedUrl("../../resources/mpris/pause.svg") 
        : Qt.resolvedUrl("../../resources/mpris/play.svg");
    
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
      elide: Text.ElideRight;
      width: 100;

      anchors {
        verticalCenter: parent.verticalCenter;
        right: parent.right;
      }
    } 
  } 

  function truncate(text) {
    if (text?.length > 40) {
        return text.substring(0, 40) + " ..."
    }
    return text
  }
}
