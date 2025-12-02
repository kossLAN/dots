import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs

RowLayout {
    spacing: 6
    visible: workspaceModel.values.length > 0

    required property var screen

    QtObject {
        id: niriState
        property var workspaces: []
        property int activeWorkspaceId: -1
        property string socketPath: Quickshell.env("NIRI_SOCKET")
        property bool initialized: false
    }

    Component.onCompleted: {
        // Request initial workspaces on startup
        if (niriState.socketPath !== "") {
            querySocket.requestWorkspaces()
        }
    }

    // Event stream socket for workspace updates
    Socket {
        id: eventSocket
        path: niriState.socketPath
        connected: path !== ""

        parser: SplitParser {
            onRead: data => {
                if (data.trim() === "") return

                try {
                    let response = JSON.parse(data)
                    eventSocket.processEventStreamMessage(response)
                } catch (e) {
                    console.error("Failed to parse Niri event:", e, data)
                }
            }
        }

        onConnectedChanged: {
            if (connected) {
                // Subscribe to event stream
                write('"EventStream"\n')
                flush()
            }
        }

        onError: error => {
            console.error("Niri event socket error:", error)
        }

        function processEventStreamMessage(msg) {
            // Event stream provides full state updates
            if (msg.Ok) {
                // Initial state or update
                if (msg.Ok.Workspaces) {
                    updateWorkspaces(msg.Ok.Workspaces)
                } else if (msg.Ok.WorkspaceActivated) {
                    niriState.activeWorkspaceId = msg.Ok.WorkspaceActivated.id
                } else if (msg.Ok.WorkspacesChanged) {
                    // Request fresh workspace list
                    querySocket.requestWorkspaces()
                }
            }
        }

        function updateWorkspaces(workspacesData) {
            // Niri workspaces format: array of workspace objects
            let workspaceList = []

            for (let ws of workspacesData) {
                workspaceList.push({
                    id: ws.id,
                    idx: ws.idx,
                    name: ws.name || "",
                    output: ws.output || "",
                    isActive: ws.is_active || false,
                    isFocused: ws.is_focused || false
                })

                if (ws.is_active) {
                    niriState.activeWorkspaceId = ws.id
                }
            }

            niriState.workspaces = workspaceList
        }
    }

    // Query socket for one-off requests (workspace switching)
    Socket {
        id: querySocket
        path: niriState.socketPath
        connected: false

        property string pendingCommand: ""

        parser: SplitParser {
            onRead: data => {
                if (data.trim() === "") return

                try {
                    let response = JSON.parse(data)
                    if (response.Ok && response.Ok.Workspaces) {
                        eventSocket.updateWorkspaces(response.Ok.Workspaces)
                    }
                } catch (e) {
                    console.error("Failed to parse Niri query response:", e, data)
                }
            }
        }

        onConnectedChanged: {
            if (connected && pendingCommand !== "") {
                write(pendingCommand + "\n")
                flush()
                pendingCommand = ""

                // Disconnect after sending command
                Qt.callLater(() => { connected = false })
            }
        }

        onError: error => {
            console.error("Niri query socket error:", error)
        }

        function requestWorkspaces() {
            pendingCommand = '"Workspaces"'
            connected = true
        }

        function focusWorkspace(index) {
            let action = {
                Action: {
                    FocusWorkspace: {
                        reference: { Index: index }
                    }
                }
            }
            pendingCommand = JSON.stringify(action)
            connected = true
        }
    }

    Repeater {
        id: workspaceButtons

        model: ScriptModel {
            id: workspaceModel
            // Filter workspaces by output/monitor if needed
            // For now, show all workspaces
            values: niriState.workspaces
        }

        Rectangle {
            radius: height / 2

            color: {
                let value = ShellSettings.colors.trim

                if (!modelData?.id || niriState.activeWorkspaceId === -1)
                    return value

                if (workspaceButton.containsMouse) {
                    value = ShellSettings.colors.highlight
                } else if (niriState.activeWorkspaceId === modelData.id) {
                    value = ShellSettings.colors.highlight
                }

                return value
            }

            Layout.alignment: Qt.AlignVCenter
            Layout.preferredHeight: 12
            Layout.preferredWidth: {
                if (niriState.activeWorkspaceId === modelData?.id)
                    return 25

                return 12
            }

            required property var modelData

            Behavior on Layout.preferredWidth {
                SmoothedAnimation {
                    duration: 150
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
                id: workspaceButton
                anchors.fill: parent
                hoverEnabled: true
                onPressed: {
                    if (parent.modelData?.idx !== undefined) {
                        querySocket.focusWorkspace(parent.modelData.idx)
                    }
                }
            }
        }
    }
}
