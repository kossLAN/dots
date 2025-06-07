import QtQuick
import Qt5Compat.GraphicalEffects
import QtQuick.Controls
import Quickshell.Widgets
import "../.."

Slider {
  id: slider;
  from: 0;
  to: 100;
  value: 50;

  background: Rectangle {
    id: sliderContainer;
    width: slider.availableWidth;
    height: slider.availableHeight;
    color: "#e0e0e0";
    radius: 10;

    layer.enabled: true
      layer.effect: OpacityMask {
        source: Rectangle {
          width: sliderContainer.width;
          height: sliderContainer.height;
          radius: sliderContainer.radius;
          color: "white";
        }

        maskSource: Rectangle {
          width: sliderContainer.width;
          height: sliderContainer.height;
          radius: sliderContainer.radius;
          color: "black";
        }
    }

    Rectangle {
      id: handle;
      width: sliderContainer.width * (slider.value / slider.to);
      height: sliderContainer.height;
      color: ShellGlobals.colors.highlight;  

      Behavior on width {
        NumberAnimation {
          duration: 100;
          easing.type: Easing.OutQuad;
        }
      }
    }

    //IconImage {
    //  implicitSize: 20;
    //  source: "root:resources/control/sleep.svg"
    //
    //  anchors {
    //    verticalCenter: parent.verticalCenter;
    //    left: parent.left;
    //    leftMargin: 15;
    //  }
    //}
  }
 
  handle: Item { }
}
