import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Services.Mpris
import "../.."

PopupWindow {  
  id: root
  width:  mediaPlayerContainer.width + 15; 
  height: mediaPlayerContainer.height + 15; 
  color: "transparent"
  visible: false
  anchor.rect.x: parentWindow.width / 2 - width / 2
  anchor.rect.y: parentWindow.height;

  HoverHandler {
    id: hoverHandler  
    enabled: true
    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
    onHoveredChanged: {
      if (hovered == false) {
        root.visible = false
      }
    }
  } 

  Rectangle {
    id: mediaPlayerContainer;
    width: 500;
    height: mediaPlayerColumn.height + 20; 
    color: ShellGlobals.colors.window
    radius: 5

    layer.enabled: true
    layer.effect: DropShadow {
      transparentBorder: true; 
      spread: 0.02;
      samples: 25; 
      color: "#80000000";
    }

    anchors.centerIn: parent;

    //border.color: hoverHandler.hovered 
    //  ? ShellGlobals.colors.highlight
    //  : ShellGlobals.colors.light
    //border.width: 2 

    ColumnLayout {
      id: mediaPlayerColumn;
      spacing: 10 

      anchors {
        top: parent.top
        left: parent.left
        right: parent.right
        margins: 10
      }

      Repeater {
        model: Mpris.players
 
        Rectangle {
          // TODO: do color quant for a background gradient and then blur it 
          required property var modelData;
          radius: 5;
          color: ShellGlobals.colors.light;
          height: 80
          Layout.fillWidth: true

          RowLayout {
            spacing: 15  
           
            anchors {
              fill: parent
              margins: 10 
            } 

            Item {
              Layout.preferredWidth: 60
              Layout.preferredHeight: 60 

              Rectangle {
                id: mask
                anchors.fill: parent
                radius: 5; 
                visible: false
              }

              Image {
                anchors.fill: parent
                source: modelData.trackArtUrl
                fillMode: Image.PreserveAspectFit
                layer.enabled: true
                layer.effect: OpacityMask {
                  maskSource: mask
                }
              }
            }  

            ColumnLayout {
              Layout.fillWidth: true  
              spacing: 5
              Layout.alignment: Qt.AlignVCenter

              Text {
                text: modelData.trackArtist;
                color: ShellGlobals.colors.text
                font.pointSize: 13
                font.bold: true 
                Layout.alignment: Qt.AlignLeft  
                Layout.fillWidth: true   
                elide: Text.ElideRight;
              }

              Text {
                text: modelData.trackTitle;
                color: ShellGlobals.colors.text;
                font.pointSize: 13;
                Layout.alignment: Qt.AlignLeft; 
                Layout.fillWidth: true;  
                elide: Text.ElideRight;
              }
            } 

            // Controls container
            RowLayout {
              spacing: 2 
              Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

              IconButton { 
                implicitSize: 24
                source: Qt.resolvedUrl("../../resources/mpris/previous.svg")
                onClicked: modelData.previous()
              }

              IconButton { 
                implicitSize: 24
                source: modelData?.isPlaying
                  ? Qt.resolvedUrl("../../resources/mpris/pause.svg") 
                  : Qt.resolvedUrl("../../resources/mpris/play.svg")
                onClicked: {
                  if (!modelData.canPlay)
                    return
                  modelData.isPlaying 
                    ? modelData.pause()
                    : modelData.play()
                }
              }

              IconButton {
                implicitSize: 24
                source: Qt.resolvedUrl("../../resources/mpris/next.svg")
                onClicked: modelData.next()
              }
            }
          }
        }
      }
    }
  }

  function truncate(text) {
    if (text?.length > 30) {
        return text.substring(0, 30) + " ..."
    }
    return text
  }
}

