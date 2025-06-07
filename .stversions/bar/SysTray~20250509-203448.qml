import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import "../widgets" as Widgets
import ".."

RowLayout {
    id: root
    required property var bar
    spacing: 10
    visible: SystemTray.items.values.length > 0

    Repeater {
        model: SystemTray.items

        Widgets.IconButton {
            id: iconButton
            implicitSize: 20
            source: modelData.icon
            padding: 0

            QsMenuAnchor {
                id: menuAnchor
                menu: modelData.menu

                anchor {
                    window: bar
                    adjustment: PopupAdjustment.Flip

                    onAnchoring: {
                        anchor.rect = mapToItem(bar.contentItem, -2, height + 4, width + 2, 0);
                    }
                }
            }

            onClicked: menuAnchor.open()
        }
    }
}
