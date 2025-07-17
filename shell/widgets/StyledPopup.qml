import QtQuick
import Quickshell
import Quickshell.Widgets
import ".."

PopupWindow {
    id: root
    color: "transparent"
    implicitWidth: container.width
    implicitHeight: container.height

    default property alias contentItem: container.children

    WrapperRectangle {
        id: container
        margin: 5
        radius: 12

        color: {
            let base = ShellSettings.colors.surface;
            return Qt.rgba(base.r, base.g, base.b, 0.15);
        }

        border {
            width: 1
            color: {
                let base = ShellSettings.colors.active;
                return Qt.rgba(base.r, base.g, base.b, 0.05);
            }
        }
    }
}
