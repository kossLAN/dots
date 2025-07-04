import QtQuick
import Quickshell.Wayland
import ".."

Text {
    id: windowText
    text: ToplevelManager.activeToplevel?.title ?? ""
    color: ShellSettings.colors["inverse_surface"]
    font.pointSize: 11
    visible: text !== ""
    elide: Text.ElideRight
}
