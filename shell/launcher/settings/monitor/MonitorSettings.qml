pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Widgets

import qs
import qs.launcher.settings
import qs.widgets
import qs.notifications
import qs.services.niri

SettingsBacker {
    icon: "cs-screen"
    summary: "Monitor Settings"

    content: Item {
        id: container

        property var outputs: ({})
        property var outputList: []
        property string selectedOutput: ""
        property var selectedOutputData: outputs[selectedOutput] ?? null
        property bool pendingSave: false

        // Generate a stable identifier for a monitor based on make/model/serial
        function getMonitorIdentifier(outputData) {
            if (!outputData)
                return "";
            const make = outputData.make ?? "Unknown";
            const model = outputData.model ?? "Unknown";
            const serial = outputData.serial ?? "";
            return `${make} ${model}${serial ? ` ${serial}` : ""}`.trim();
        }

        property var pendingConfig: null
        property string pendingMonitorId: ""
        property string pendingOutputName: ""
        property var activeConfirmNotification: null

        // Request a save after the next output refresh
        function requestSave() {
            pendingSave = true;
        }

        function confirmSave() {
            if (!pendingConfig || !pendingMonitorId)
                return;

            const newOutputs = Object.assign({}, ShellSettings.outputs ?? {});
            newOutputs[pendingMonitorId] = pendingConfig;
            ShellSettings.outputs = newOutputs;

            console.log("Monitor config saved for", pendingMonitorId);
            pendingConfig = null;
            pendingMonitorId = "";
            pendingOutputName = "";
            activeConfirmNotification = null;
        }

        function revertConfig() {
            if (!pendingMonitorId || !pendingOutputName) {
                activeConfirmNotification = null;
                return;
            }

            const outputName = pendingOutputName;
            const oldConfig = (ShellSettings.outputs ?? {})[pendingMonitorId];

            pendingConfig = null;
            pendingMonitorId = "";
            pendingOutputName = "";
            activeConfirmNotification = null;

            if (oldConfig) {
                if (oldConfig.mode)
                    Niri.setOutputMode(outputName, oldConfig.mode);
                if (oldConfig.scale !== undefined)
                    Niri.setOutputScale(outputName, oldConfig.scale);
                if (oldConfig.transform !== undefined)
                    Niri.setOutputTransform(outputName, oldConfig.transform);
                if (oldConfig.vrr !== undefined)
                    Niri.setOutputVrr(outputName, oldConfig.vrr);
            }

            console.log("Monitor config reverted for", outputName);
        }

        // Build config from current output state and show confirmation notification
        function saveCurrentConfig() {
            if (!selectedOutput || !selectedOutputData)
                return;

            const monitorId = getMonitorIdentifier(selectedOutputData);
            if (!monitorId)
                return;

            const currentMode = selectedOutputData.modes?.[selectedOutputData.current_mode ?? 0];
            const config = {
                enabled: true,
                scale: selectedOutputData.logical?.scale ?? 1.0,
                transform: selectedOutputData.logical?.transform ?? "Normal",
                position: {
                    x: selectedOutputData.logical?.x ?? 0,
                    y: selectedOutputData.logical?.y ?? 0
                },
                vrr: {
                    vrr: selectedOutputData.vrr_enabled ?? false,
                    on_demand: false
                }
            };

            if (currentMode) {
                config.mode = {
                    width: currentMode.width,
                    height: currentMode.height,
                    refresh: currentMode.refresh_rate / 1000.0
                };
            }

            if (activeConfirmNotification)
                activeConfirmNotification.discard();

            pendingConfig = config;
            pendingMonitorId = monitorId;
            pendingOutputName = selectedOutput;

            const notif = savedNotification.createObject(null);
            activeConfirmNotification = notif;
            Notifications.addNotification(notif);
        }

        Connections {
            target: Niri.state

            function onOutputsChanged() {
                container.outputs = Niri.state.outputs;
                container.outputList = Object.keys(Niri.state.outputs);

                if (container.outputList.length > 0 && container.selectedOutput === "") {
                    container.selectedOutput = container.outputList[0];
                }

                if (container.pendingSave) {
                    container.pendingSave = false;
                    container.saveCurrentConfig();
                }
            }
        }

        Component.onCompleted: {
            Niri.refreshOutputs();
        }

        property Component savedNotification: NotificationBacker {
            id: toast

            property int countdown: 15

            summary: "Keep display settings?"

            Timer {
                interval: 1000
                repeat: true
                running: true
                onTriggered: {
                    toast.countdown--;
                    if (toast.countdown <= 0) {
                        stop();
                        container.revertConfig();
                        toast.discard();
                    }
                }
            }

            body: Text {
                color: ShellSettings.colors.active.text.darker(1.25)
                font.pixelSize: 12
                text: `Reverting in ${toast.countdown}s...`
            }

            icon: IconImage {
                source: Quickshell.iconPath("cs-screen")
                implicitSize: 36
            }

            buttons: RowLayout {
                spacing: 8

                IconButton {
                    color: ShellSettings.colors.active.light
                    source: Quickshell.iconPath("dialog-ok-apply")
                    implicitSize: 16
                    onClicked: {
                        container.confirmSave();
                        toast.discard();
                    }
                }

                IconButton {
                    color: ShellSettings.colors.active.light
                    source: Quickshell.iconPath("window-close")
                    implicitSize: 16
                    onClicked: {
                        container.revertConfig();
                        toast.discard();
                    }
                }
            }
        }

        ColumnLayout {
            id: root
            spacing: 12

            anchors {
                fill: parent
                margins: 8
            }

            MonitorPreview {
                outputs: container.outputs
                outputList: container.outputList
                selectedOutput: container.selectedOutput
                onSelectedOutputChanged: container.selectedOutput = selectedOutput

                Layout.fillWidth: true
                Layout.preferredHeight: 225
            }

            MonitorDetails {
                selectedOutput: container.selectedOutput
                outputs: container.outputs

                onSaveConfig: container.requestSave()

                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            Item {
                visible: container.selectedOutput === "" && container.outputList.length > 0

                Layout.fillWidth: true
                Layout.fillHeight: true

                StyledText {
                    text: "Select a display to view details"
                    color: ShellSettings.colors.active.windowText.darker(1.5)
                    font.pointSize: 9
                    anchors.centerIn: parent
                }
            }
        }
    }
}
