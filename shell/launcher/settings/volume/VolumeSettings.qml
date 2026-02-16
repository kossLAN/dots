pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire

import qs
import qs.widgets
import qs.launcher.settings

SettingsBacker {
    icon: "audio-volume-high"
    summary: "Volume Settings"
    label: "Volume"

    content: Item {
        id: container

        property int currentTab: 0

        // Get all audio sinks (output devices) - filter out streams
        property var audioSinks: {
            if (!Pipewire.nodes)
                return [];
            return Pipewire.nodes.values.filter(node => node.isSink && node.audio !== null && !node.isStream);
        }

        property var audioSources: {
            if (!Pipewire.nodes)
                return [];

            return Pipewire.nodes.values.filter(node => !node.isSink && node.audio !== null && !node.isStream);
        }

        // Link tracker for default sink to get applications
        PwNodeLinkTracker {
            id: linkTracker
            node: Pipewire.defaultAudioSink
        }

        ColumnLayout {
            id: root
            spacing: 8

            anchors {
                fill: parent
                margins: 8
            }

            // Tab Bar
            TopBar {
                id: tabBar
                color: ShellSettings.colors.active.base
                model: ["applications-multimedia", "audio-speakers", "audio-input-microphone"]
                currentIndex: container.currentTab
                onCurrentIndexChanged: container.currentTab = currentIndex

                Layout.fillWidth: true
                Layout.preferredHeight: 36
            }

            StackLayout {
                currentIndex: container.currentTab

                Layout.fillWidth: true
                Layout.fillHeight: true

                ApplicationsPage {
                    audioSinks: container.audioSinks
                    linkTracker: linkTracker
                }

                NodePage {
                    nodes: container.audioSinks
                    defaultNode: Pipewire.defaultAudioSink
                    title: "Default Output"
                    icon: "audio-volume-high"
                    mutedIcon: "audio-volume-muted"
                    emptyText: "No output devices found"
                    onSetDefault: node => Pipewire.preferredDefaultAudioSink = node
                }

                NodePage {
                    nodes: container.audioSources
                    defaultNode: Pipewire.defaultAudioSource
                    title: "Default Input"
                    icon: "audio-input-microphone"
                    mutedIcon: "microphone-sensitivity-muted"
                    emptyText: "No input devices found"
                    onSetDefault: node => Pipewire.preferredDefaultAudioSource = node
                }
            }
        }
    }
}
