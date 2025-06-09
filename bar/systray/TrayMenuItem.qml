import Quickshell
import QtQuick
import QtQuick.Layouts
import "../.."

ColumnLayout {
    id: root
    required property QsMenuEntry modelData
    required property var rootMenu
    property var leftItem
    signal interacted

    Rectangle {
        visible: (root.modelData?.isSeparator ?? false)
        color: ShellSettings.settings.colors["surface_container_high"]
        Layout.fillWidth: true
        Layout.preferredHeight: 2
        Layout.leftMargin: 8
        Layout.rightMargin: 8
    }

    TrayMenuEntry {
        visible: !root.modelData?.isSeparator
        rootMenu: root.rootMenu
        menuData: root.modelData
        Layout.fillWidth: true
        onInteracted: root.interacted()
    }
}
