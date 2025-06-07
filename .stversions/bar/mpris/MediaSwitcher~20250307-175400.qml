import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Services.Mpris
import "../../widgets/" as Widgets 
import "../.."

PopupWindow {  
  id: root
  width:  mediaPlayerContainer.width + 10; 
  height: mediaPlayerContainer.height + 10; 
  color: "transparent"
  visible: mediaPlayerContainer.opacity > 0; 

  anchor.rect.x: parentWindow.width / 2 - width / 2;
  anchor.rect.y: parentWindow.height; 

  function show() { 
    mediaPlayerContainer.opacity = 1;
  }

  function hide() {
    mediaPlayerContainer.opacity = 0;
  }

  HoverHandler {
    id: hoverHandler; 
    enabled: true;
    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad;
    onHoveredChanged: {
      if (hovered == false) {
        hide(); 
      }
    }
  }

  Rectangle {
    id: mediaPlayerContainer;
    width: 500;
    height: mediaPlayerColumn.height + 20; 
    color: ShellGlobals.colors.window;
    radius: 5; 
    opacity: 0;

    layer.enabled: true;
    layer.effect: DropShadow {
      transparentBorder: true; 
      spread: 0.02;
      samples: 25; 
      color: "#80000000";
    }

    anchors.centerIn: parent;    

    Behavior on opacity {
      NumberAnimation {
        duration: 300;
        easing.type: Easing.OutCubic;
      }
    }

    
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
          required property var modelData;
          radius: 5;
          color: ShellGlobals.colors.midlight;
          border.color: ShellGlobals.colors.light;
          height: 75;
          Layout.fillWidth: true;

          RowLayout {
            spacing: 15;


            anchors {
              fill: parent;
              leftMargin: 10;
              rightMargin: 10;
              topMargin: 0;
              bottomMargin: 0;
            }

            Item {
              Layout.preferredWidth: 60;
              Layout.preferredHeight: 60; 
              Layout.alignment: Qt.AlignVCenter;
              visible: modelData.trackArtUrl != "";

              Rectangle {
                id: mask;
                anchors.fill: parent;
                radius: 5;
                visible: false;
              }

              Image {
                anchors.fill: parent;
                source: modelData.trackArtUrl;
                fillMode: Image.PreserveAspectFit;
                layer.enabled: true;
                layer.effect: OpacityMask {
                  maskSource: mask;
                }
              }
            }  

            ColumnLayout {
              Layout.fillWidth: true;
              Layout.fillHeight: true;  
              spacing: 5;
              Layout.alignment: Qt.AlignVCenter;

              Item { Layout.fillHeight: true; } 

              Text {
                text: modelData.trackArtist;
                color: ShellGlobals.colors.text;
                font.pointSize: 13;
                font.bold: true;
                Layout.alignment: Qt.AlignLeft;
                Layout.fillWidth: true;
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

              Item { Layout.fillHeight: true; } 
            } 

            RowLayout {
              spacing: 2;
              Layout.alignment: Qt.AlignRight | Qt.AlignVCenter;

              Widgets.IconButton { 
                implicitSize: 28;
                padding: 4;
                source: "root:resources/mpris/previous.svg";
                onClicked: modelData.previous();
              }

              Widgets.IconButton { 
                implicitSize: 28;
                padding: 4;
                source: modelData?.isPlaying
                  ? "root:resources/mpris/pause.svg" 
                  : "root:resources/mpris/play.svg";
                onClicked: {
                  if (!modelData.canPlay)
                    return;
                  modelData.isPlaying 
                    ? modelData.pause()
                    : modelData.play();
                }
              }

              Widgets.IconButton {
                implicitSize: 28;
                padding: 4;
                source: "root:resources/mpris/next.svg";
                onClicked: modelData.next();
              }
            }
          }
        }
      }
    }
  }
}

