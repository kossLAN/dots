pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs
import qs.widgets
import qs.services.niri

Item {
    id: root

    required property var screen

    property var activeWorkspace: Niri.state.activeWorkspaces.filter(workspace => {
        return workspace.output === root.screen.name;
    })[0]

    property var sortedWindows: Niri.state.windows.filter(w => w.workspace_id === root.activeWorkspace.id).sort((a, b) => {
        if (a.is_floating)
            return b;

        const pa = a.layout.pos_in_scrolling_layout;
        const pb = b.layout.pos_in_scrolling_layout;

        if (pa == null || pb == null)
            return b;

        return pa[0] !== pb[0] ? pa[0] - pb[0] : pa[1] - pb[1];
    })

    property int itemSize: height + layout.spacing

    Layout.preferredWidth: (workspaceList.count + 1) * itemSize

    RowLayout {
        id: layout
        anchors.fill: parent

        StyledMouseArea {
            Layout.preferredWidth: height
            Layout.fillHeight: true

            onClicked: Niri.toggleOverview();

            Text {
                id: workspaceNumber
                text: displayedTitle
                color: ShellSettings.colors.active.text
                anchors.centerIn: parent

                property string activeTitle: root.activeWorkspace?.idx ?? "0"
                property string displayedTitle: activeTitle

                onActiveTitleChanged: fadeOut.start()

                NumberAnimation {
                    id: fadeOut
                    target: workspaceNumber
                    property: "opacity"
                    to: 0
                    duration: 100
                    onFinished: {
                        workspaceNumber.displayedTitle = workspaceNumber.activeTitle;
                        fadeIn.start();
                    }
                }

                NumberAnimation {
                    id: fadeIn
                    target: workspaceNumber
                    property: "opacity"
                    to: 1
                    duration: 100
                }
            }
        }

        StyledListView {
            id: workspaceList
            clip: true
            orientation: ListView.Horizontal
            spacing: layout.spacing
            interactive: false

            highlightMoveVelocity: -1
            highlightMoveDuration: 200
            highlightRangeMode: ListView.ApplyRange
            snapMode: ListView.SnapToItem

            preferredHighlightBegin: 0
            preferredHighlightEnd: width - height

            currentIndex: {
                let index = 0;
                let focusedIndex = 0;

                sortedWindows.forEach(window => {
                    index++;

                    if (window.is_focused)
                        focusedIndex = index;
                });

                return focusedIndex - 1;
            }

            Layout.fillWidth: true
            Layout.fillHeight: true

            model: ScriptModel {
                objectProp: "id"

                values: root.sortedWindows
            }

            highlight: Rectangle {
                color: ShellSettings.colors.active.accent
            }

            delegate: StyledMouseArea {
                id: workspaceButton
                radius: 0
                hoverColor: modelData.is_focused ? "transparent" : ShellSettings.colors.inactive.accent
                onClicked: Niri.focusWindow(modelData.id)

                required property var modelData

                implicitWidth: ListView.view.height
                implicitHeight: ListView.view.height

                Rectangle {
                    visible: workspaceButton.modelData.is_urgent
                    color: "#e67b10"
                    anchors.fill: parent
                }

                IconImage {
                    id: appIcon

                    source: {
                        // If app_id is "" its absolutely cooked
                        if (workspaceButton.modelData.app_id === "")
                            return Quickshell.iconPath("error");

                        // Try for desktop entry first
                        const desktopIcon = DesktopEntries.byId(workspaceButton.modelData.app_id)?.icon ?? "";
                        const icon = Quickshell.iconPath(desktopIcon, true);

                        if (icon != "")
                            return icon;

                        // Fuck it last resort
                        return Quickshell.iconPath(workspaceButton.modelData.app_id, "error");
                    }

                    anchors {
                        fill: parent
                        margins: 1
                    }
                }
            }
        }
    }
}
