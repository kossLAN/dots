import QtQuick
import "../../widgets/" as Widgets

Item {
    id: root

    required property var popup

    Widgets.FontIconButton {
        id: button
        iconName: "volume_up"
        anchors.fill: parent
        onClicked: {
            if (root.popup.content == volumeMenu) {
                root.popup.hide();
                return;
            }

            root.popup.set(this, volumeMenu);
            root.popup.show();
        }
    }

    VolumeControl {
        id: volumeMenu
    }
}
