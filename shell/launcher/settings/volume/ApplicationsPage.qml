pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import qs
import qs.widgets

Item {
    id: root

    required property var audioSinks
    required property PwNodeLinkTracker linkTracker

    ColumnLayout {
        spacing: 6
        anchors.fill: parent

        // Applications Header
        RowLayout {
            spacing: 6
            Layout.fillWidth: true

            StyledText {
                text: "Applications"
                font.pointSize: 9
            }

            Item {
                Layout.fillWidth: true
            }

            StyledText {
                text: `${root.linkTracker.linkGroups.length} playing`
                color: ShellSettings.colors.active.windowText.darker(1.5)
                font.pointSize: 9
            }
        }

        Separator {
            Layout.fillWidth: true
        }

        // Applications List
        StyledListView {
            id: appList
            model: root.linkTracker.linkGroups
            spacing: 4
            clip: true
            visible: root.linkTracker.linkGroups.length > 0

            Layout.fillWidth: true
            Layout.fillHeight: true

            delegate: StyledRectangle {
                id: appCard
                color: ShellSettings.colors.active.base
                clip: true

                required property PwLinkGroup modelData
                required property int index

                property PwNode appNode: modelData?.source ?? null
                property bool expanded: false
                property int collapsedHeight: 76
                property int expandedHeight: 8 + collapsedHeight + dropdownContent.implicitHeight

                implicitWidth: ListView.view.width
                implicitHeight: expanded ? expandedHeight : collapsedHeight

                PwObjectTracker {
                    objects: [appCard.appNode]
                }

                PwNodePeakMonitor {
                    id: peakMonitor
                    node: appCard.appNode
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: appCard.expanded = !appCard.expanded
                }

                Behavior on implicitHeight {
                    SmoothedAnimation {
                        duration: 200
                    }
                }

                ColumnLayout {
                    spacing: 4

                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        margins: 8
                    }

                    RowLayout {
                        id: appMainRow
                        spacing: 8
                        Layout.fillWidth: true

                        StyledMouseArea {
                            enabled: appCard.appNode?.audio !== null
                            Layout.preferredWidth: 28
                            Layout.preferredHeight: 28

                            onClicked: {
                                if (appCard.appNode?.audio) {
                                    appCard.appNode.audio.muted = !appCard.appNode.audio.muted;
                                }
                            }

                            IconImage {
                                id: appIcon
                                visible: false
                                anchors.fill: parent
                                anchors.margins: 2

                                source: {
                                    const props = appCard.appNode?.properties;
                                    const fallbackIcon = "application-x-executable";

                                    if (!props)
                                        return Quickshell.iconPath("application-x-executable");

                                    if (props["application.icon-name"] !== undefined) {
                                        const iconName = props["application.icon-name"];
                                        const appEntryIcon = DesktopEntries.heuristicLookup(iconName)?.icon ?? "";

                                        return Quickshell.iconPath(appEntryIcon, iconName);
                                    }

                                    if (props["application.name"] !== undefined) {
                                        const applicationName = props["application.name"];
                                        const appEntryIcon = DesktopEntries.heuristicLookup(applicationName)?.icon ?? "";

                                        return Quickshell.iconPath(appEntryIcon, fallbackIcon);
                                    }

                                    return Quickshell.iconPath(fallbackIcon);
                                }
                            }

                            MultiEffect {
                                source: appIcon
                                anchors.fill: appIcon
                                saturation: appCard.appNode?.audio?.muted ? -1.0 : 0.0
                            }
                        }

                        ColumnLayout {
                            spacing: 2
                            Layout.fillWidth: true

                            StyledText {
                                text: appCard.appNode?.properties["media.name"] ?? appCard.appNode?.properties["application.name"] ?? "Unknown"
                                font.pointSize: 9
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            RowLayout {
                                spacing: 4
                                Layout.fillWidth: true

                                StyledText {
                                    text: appCard.appNode?.properties["application.name"] ?? ""
                                    color: ShellSettings.colors.active.windowText.darker(1.5)
                                    font.pointSize: 9
                                    elide: Text.ElideRight
                                }

                                Rectangle {
                                    visible: appCard.appNode?.audio?.muted ?? false
                                    radius: 3
                                    color: ShellSettings.colors.active.dark
                                    Layout.preferredWidth: mutedText.implicitWidth + 6
                                    Layout.preferredHeight: mutedText.implicitHeight + 2

                                    StyledText {
                                        id: mutedText
                                        text: "Muted"
                                        font.pointSize: 9
                                        color: ShellSettings.colors.active.windowText
                                        anchors.centerIn: parent
                                    }
                                }
                            }
                        }

                        ExpandArrow {
                            expanded: appCard.expanded
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                        }
                    }

                    // Peak meter bar
                    Rectangle {
                        color: ShellSettings.colors.active.light
                        radius: 2

                        Layout.fillWidth: true
                        Layout.preferredHeight: 3
                        Layout.leftMargin: 6
                        Layout.rightMargin: 6

                        Rectangle {
                            width: parent.width * peakMonitor.peak
                            height: parent.height
                            radius: parent.radius
                            color: ShellSettings.colors.active.highlight

                            Behavior on width {
                                SmoothedAnimation {
                                    duration: 50
                                }
                            }
                        }
                    }

                    Item {
                        Layout.preferredHeight: 2
                    }

                    // Full width volume slider
                    StyledSlider {
                        implicitHeight: 6
                        handleHeight: 12
                        value: appCard.appNode?.audio?.volume ?? 0

                        Layout.fillWidth: true
                        Layout.leftMargin: 6
                        Layout.rightMargin: 6

                        onValueChanged: {
                            if (!appCard.appNode || !appCard.appNode.audio || !appCard.appNode.ready)
                                return;

                            appCard.appNode.audio.volume = value;
                        }
                    }
                }

                // Dropdown content for output routing
                ColumnLayout {
                    id: dropdownContent
                    spacing: 6
                    opacity: appCard.expanded ? 1 : 0
                    visible: opacity > 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 150
                        }
                    }

                    anchors {
                        top: parent.top
                        topMargin: appCard.collapsedHeight
                        left: parent.left
                        right: parent.right
                        margins: 8
                    }

                    Rectangle {
                        color: ShellSettings.colors.active.mid
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                    }

                    StyledText {
                        text: "Route to:"
                        font.pointSize: 9
                        color: ShellSettings.colors.active.windowText.darker(1.5)
                    }

                    Repeater {
                        model: root.audioSinks

                        delegate: StyledMouseArea {
                            id: routeOption

                            required property PwNode modelData
                            required property int index

                            property bool isCurrentTarget: appCard.modelData?.target === modelData

                            Layout.fillWidth: true
                            Layout.preferredHeight: 28
                            radius: 6

                            onClicked: {
                                if (appCard.appNode && modelData) {
                                    // NOTE: not possible as of now, but in the future should be
                                }
                            }

                            RowLayout {
                                spacing: 6
                                anchors {
                                    fill: parent
                                    leftMargin: 8
                                    rightMargin: 8
                                }

                                IconImage {
                                    source: Quickshell.iconPath("audio-speakers")
                                    Layout.preferredWidth: 16
                                    Layout.preferredHeight: 16
                                }

                                StyledText {
                                    text: routeOption.modelData ? (routeOption.modelData.nickname || routeOption.modelData.description) : "Unknown"
                                    font.pointSize: 9
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                RadioButton {
                                    checked: routeOption.isCurrentTarget
                                    Layout.preferredWidth: 16
                                    Layout.preferredHeight: 16
                                }
                            }
                        }
                    }
                }
            }
        }

        // Empty state for applications
        Item {
            visible: root.linkTracker.linkGroups.length === 0
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 12

                IconImage {
                    source: Quickshell.iconPath("audio-volume-high")
                    Layout.preferredWidth: 48
                    Layout.preferredHeight: 48
                    Layout.alignment: Qt.AlignHCenter
                    opacity: 0.5
                }

                StyledText {
                    text: "No applications playing audio"
                    horizontalAlignment: Text.AlignHCenter
                    color: ShellSettings.colors.active.windowText.darker(1.5)
                    font.pointSize: 9
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
    }
}
