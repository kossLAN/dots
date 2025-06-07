import QtQuick
import Quickshell.Widgets
import Quickshell.Services.UPower
import ".." 

Item {
  property string batteryStatus: {
    if (!UPower.onBattery) {
        return "charging";
    }

    let percentage = UPower.displayDevice.percentage * 100; 
    let roundedValue = Math.floor(percentage / 5) * 5;
    return roundedValue.toString();
  } 

  width: 30; 
  height: parent.height; 
  visible: UPower.displayDevice.isLaptopBattery;

  Rectangle {
    color: ShellGlobals.colors.highlight;
    width: 12;
    height: 8;
    visible: batteryStatus === "charging";

    anchors {
      centerIn: batteryImage;
    }
  }

  IconImage {
    id: batteryImage;
    implicitSize: 20;
    source: Qt.resolvedUrl(`../resources/battery/battery-${batteryStatus}.svg`); 
    anchors.centerIn: parent; 
  } 
}
