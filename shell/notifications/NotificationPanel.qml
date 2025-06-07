import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: window

    property alias view: view

    property real toastWidth: 525
    property real overshoot: 40
    property real gaps: 5

    color: "transparent"
    implicitWidth: window.toastWidth + window.overshoot + (2 * gaps)
    mask: view.mask

    WlrLayershell.namespace: "shell:notifs"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusionMode: ExclusionMode.Normal

    anchors {
        top: true
        bottom: true
        right: true
    }

    NotificationView {
        id: view
        toastWidth: window.toastWidth
        overshoot: window.overshoot

        anchors {
            fill: parent
            topMargin: window.gaps
            bottomMargin: window.gaps
            rightMargin: window.gaps
            leftMargin: window.gaps + window.overshoot
        }
    }
}
