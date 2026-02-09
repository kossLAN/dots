pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs
import qs.launcher.settings
import qs.widgets
import qs.services.niri

SettingsBacker {
    icon: "cs-screen"

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

        // Request a save after the next output refresh
        function requestSave() {
            pendingSave = true;
        }

        // Save current output configuration to system config
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

            const newOutputs = Object.assign({}, ShellSettings.outputs ?? {});
            newOutputs[monitorId] = config;

            ShellSettings.outputs = newOutputs;
            console.log("Monitor config saved for", monitorId, ":", JSON.stringify(ShellSettings.outputs));
        }

        Connections {
            target: Niri.state
            function onOutputsChanged() {
                container.outputs = Niri.state.outputs;
                container.outputList = Object.keys(Niri.state.outputs);
                if (container.outputList.length > 0 && container.selectedOutput === "") {
                    container.selectedOutput = container.outputList[0];
                }
                // Save after outputs are refreshed if a save was requested
                if (container.pendingSave) {
                    container.pendingSave = false;
                    container.saveCurrentConfig();
                }
            }
        }

        Component.onCompleted: {
            Niri.refreshOutputs();
        }

        ColumnLayout {
            id: root
            spacing: 12
            anchors.fill: parent

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
