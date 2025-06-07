pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Polkit

Scope {
    id: root

    PolkitAgent {
        id: agent

        onIsRegisteredChanged: console.info("Polkit Agent Started")

        onIsActiveChanged: {
            if (isActive && isRegistered) {
                console.info("Polkit Agent Request Received");
            }
        }
    }

    LazyLoader {
        active: agent.isActive

        PanelWindow {
            visible: true
            color: "transparent"
            exclusiveZone: 0

            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            WlrLayershell.namespace: "shell:polkit"

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            Rectangle {
                color: "black"
                opacity: 0.5
                anchors.fill: parent
            }

            PolkitDialog {
                flow: agent.flow
                anchors.centerIn: parent
            }
        }
    }
}
