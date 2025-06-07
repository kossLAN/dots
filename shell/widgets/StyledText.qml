import QtQuick 
import qs

Text {
    id: root

    property color textColor: ShellSettings.colors.active.windowText

    color: textColor
    renderType: Text.NativeRendering
}
