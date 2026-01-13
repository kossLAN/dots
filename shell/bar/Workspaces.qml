pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs

RowLayout {
    id: root

    required property var screen
    property string socketPath: Quickshell.env("NIRI_SOCKET")
    property var workspaces: []

    Repeater {
        model: ScriptModel {
            objectProp: "idx"

            values: root.workspaces.filter(workspace => {
                return workspace.output === root.screen.name;
            }).sort((a, b) => a.idx - b.idx)
        }

        delegate: Rectangle {
            id: wsButton
            radius: height / 2

            color: {
                if (modelData.is_active)
                    return ShellSettings.colors.highlight;
                else if (modelData.is_urgent)
                    return ShellSettings.colors.accent;

                return ShellSettings.colors.trim;
            }

            required property var modelData

            Layout.preferredWidth: modelData.is_active ? 25 : 12
            Layout.preferredHeight: 12
            Layout.alignment: Qt.AlignVCenter

            // Text {
            //     text: wsButton.modelData.idx
            //     anchors.centerIn: parent
            // }

            Behavior on width {
                SmoothedAnimation {
                    duration: 5000
                    velocity: 200
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 100
                    easing.type: Easing.OutQuad
                }
            }

            MouseArea {
                hoverEnabled: true
                onClicked: querySocket.focusWorkspace(wsButton.modelData.idx)
                anchors.fill: parent
            }
        }
    }

    Socket {
        id: eventStreamSocket
        path: root.socketPath
        connected: true

        parser: SplitParser {
            onRead: data => {
                if (data.trim() === "")
                    return;

                try {
                    let response = JSON.parse(data);
                    eventStreamSocket.processEventStream(response);
                } catch (e) {
                    console.error("Failed to parse Niri event:", e, data);
                }
            }
        }

        onConnectedChanged: {
            if (connected) {
                // Listen to event stream
                write('"EventStream"\n');
                flush();

                // Call update for initial state
                querySocket.update();
            }
        }

        function processEventStream(msg) {
            // If workspace is changed/activated/etc we call for an update
            if (msg.WorkspaceActivated || msg.WorkspacesChanged || msg.WorkspaceUrgencyChanged) {
                querySocket.update();
            }
        }
    }

    Socket {
        id: querySocket
        path: root.socketPath
        connected: true

        parser: SplitParser {
            onRead: data => {
                if (data.trim() === "")
                    return;

                // console.log(data);

                try {
                    let response = JSON.parse(data);
                    querySocket.processQueryResponse(response);
                } catch (e) {
                    console.error("Failed to parse Niri event:", e, data);
                }
            }
        }

        function processQueryResponse(msg) {
            if (!msg.Ok)
                return;

            if (msg.Ok.Workspaces) {
                root.workspaces = msg.Ok.Workspaces;
                return;
            }
        }

        // Updates the workspace state
        function update() {
            querySocket.write('"Workspaces"\n');
        }

        function focusWorkspace(id) {
            let action = {
                Action: {
                    FocusWorkspace: {
                        reference: {
                            Index: id
                        }
                    }
                }
            };

            querySocket.write(`${JSON.stringify(action)}\n`);
        }
    }
}
