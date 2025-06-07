import QtQuick
import Quickshell.Io

JsonObject {
    property bool enabled: true
    property real scale: 1.0
    property string transform: "Normal"
    property MonitorMode mode: MonitorMode {}
    property MonitorPosition position: MonitorPosition {}
    property MonitorVrr vrr: MonitorVrr {}
}
