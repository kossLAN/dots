import QtQuick
import Quickshell

Scope {
    property bool enabled: true
    property string icon
    property string summary: ""
    property string label: summary
    property Component content
}
