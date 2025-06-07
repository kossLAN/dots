import Quickshell
import QtQuick
import "../../widgets/" as Widgets

Widgets.IconButton {
    id: root
    required property var bar
    required property var screen

    implicitSize: 20
    source: "root:/resources/general/nixos.svg"
    padding: 2

    onClicked: {
        if (controlPanel.visible) {
            controlPanel.hide();
        } else {
            controlPanel.show();
        }
    }

    ControlPanel {
        id: controlPanel

        anchor {
            window: root.screen

            onAnchoring: {
                anchor.rect = mapToItem(root.screen.contentItem, 0, root.screen.height, width, 0);
            }
        }
    }
}
