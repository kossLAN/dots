pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs

Singleton {
    id: root

    property string socketPath: Quickshell.env("NIRI_SOCKET")
    property bool configApplied: false

    property QtObject state: QtObject {
        property var workspaces: []
        property var windows: []
        property var outputs: ({})

        property var activeWorkspaces: workspaces.filter(workspace => {
            return workspace.is_active == true;
        })
    }

    Socket {
        id: eventStreamSocket
        path: root.socketPath
        connected: true

        parser: SplitParser {
            onRead: data => {
                if (data.trim() === "")
                    return;

                // console.log(data);

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
                console.info("Connected to Niri IPC");
                write('"EventStream"\n');
                flush();

                // Call update for initial state
                root.refreshWorkspaces();
                root.refreshWindows();
                root.refreshOutputs();
            }
        }

        function processEventStream(msg) {
            // If workspace is changed/activated/etc we call for an update
            if (msg.WorkspaceActivated || msg.WorkspacesChanged || msg.WorkspaceUrgencyChanged) {
                root.refreshWorkspaces();
            } else if (msg.WindowOpenedOrChanged || msg.WindowClosed || msg.WindowFocusChanged || msg.WindowLayoutsChanged || msg.WindowsChanged) {
                root.refreshWindows();
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
                root.state.workspaces = msg.Ok.Workspaces;
            } else if (msg.Ok.Windows) {
                root.state.windows = msg.Ok.Windows;
            } else if (msg.Ok.Outputs) {
                root.state.outputs = msg.Ok.Outputs;
            }
        }
    }

    function refreshWorkspaces() {
        querySocket.write('"Workspaces"\n');
    }

    function refreshWindows() {
        querySocket.write('"Windows"\n');
    }

    function refreshOutputs() {
        querySocket.write('"Outputs"\n');
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

    function focusWindow(id) {
        let action = {
            Action: {
                FocusWindow: {
                    id: id
                }
            }
        };

        querySocket.write(`${JSON.stringify(action)}\n`);
    }

    function toggleOverview() {
        let action = {
            Action: {
                ToggleOverview: {}
            }
        };

        querySocket.write(`${JSON.stringify(action)}\n`);
    }

    function dpms(on) {
        let action;

        if (on) {
            action = {
                Action: {
                    PowerOnMonitors: {}
                }
            };
        } else {
            action = {
                Action: {
                    PowerOffMonitors: {}
                }
            };
        }

        querySocket.write(`${JSON.stringify(action)}\n`);
    }

    // Timer to delay refresh after output changes
    Timer {
        id: outputRefreshTimer
        interval: 200
        onTriggered: root.refreshOutputs()
    }

    function scheduleOutputRefresh() {
        outputRefreshTimer.restart();
    }

    function setOutputOff(outputName) {
        let action = {
            Output: {
                output: outputName,
                action: "Off"
            }
        };

        querySocket.write(`${JSON.stringify(action)}\n`);
        scheduleOutputRefresh();
    }

    function setOutputOn(outputName) {
        let action = {
            Output: {
                output: outputName,
                action: "On"
            }
        };

        querySocket.write(`${JSON.stringify(action)}\n`);
        scheduleOutputRefresh();
    }

    function setOutputMode(outputName, mode) {
        let modeValue;

        if (mode === "Automatic") {
            modeValue = "Automatic";
        } else {
            modeValue = {
                Specific: {
                    width: mode.width,
                    height: mode.height,
                    refresh: mode.refresh ?? null
                }
            };
        }

        let action = {
            Output: {
                output: outputName,
                action: {
                    Mode: {
                        mode: modeValue
                    }
                }
            }
        };

        querySocket.write(`${JSON.stringify(action)}\n`);
        scheduleOutputRefresh();
    }

    function setOutputScale(outputName, scale) {
        let scaleValue;

        if (scale === "Automatic") {
            scaleValue = "Automatic";
        } else {
            scaleValue = {
                Specific: scale
            };
        }

        let action = {
            Output: {
                output: outputName,
                action: {
                    Scale: {
                        scale: scaleValue
                    }
                }
            }
        };

        querySocket.write(`${JSON.stringify(action)}\n`);
        scheduleOutputRefresh();
    }

    function setOutputTransform(outputName, transform) {
        let action = {
            Output: {
                output: outputName,
                action: {
                    Transform: {
                        transform: transform
                    }
                }
            }
        };

        querySocket.write(`${JSON.stringify(action)}\n`);
        scheduleOutputRefresh();
    }

    function setOutputPosition(outputName, position) {
        let positionValue;

        if (position === "Automatic") {
            positionValue = "Automatic";
        } else {
            positionValue = {
                Specific: {
                    x: position.x,
                    y: position.y
                }
            };
        }

        let action = {
            Output: {
                output: outputName,
                action: {
                    Position: {
                        position: positionValue
                    }
                }
            }
        };

        querySocket.write(`${JSON.stringify(action)}\n`);
        scheduleOutputRefresh();
    }

    function setOutputVrr(outputName, vrrConfig) {
        let action = {
            Output: {
                output: outputName,
                action: {
                    Vrr: {
                        vrr: {
                            vrr: vrrConfig.vrr ?? false,
                            on_demand: vrrConfig.on_demand ?? false
                        }
                    }
                }
            }
        };

        querySocket.write(`${JSON.stringify(action)}\n`);
        scheduleOutputRefresh();
    }

    // Generate a stable identifier for a monitor based on make/model/serial
    function getMonitorIdentifier(outputData) {
        if (!outputData)
            return "";
        const make = outputData.make ?? "Unknown";
        const model = outputData.model ?? "Unknown";
        const serial = outputData.serial ?? "";
        return `${make} ${model}${serial ? ` ${serial}` : ""}`.trim();
    }

    // Find saved config for an output by its monitor identifier
    function findSavedConfig(outputName) {
        const savedOutputs = ShellSettings.outputs ?? {};
        const outputData = root.state.outputs[outputName];

        if (!outputData)
            return null;

        const monitorId = getMonitorIdentifier(outputData);
        return savedOutputs[monitorId] ?? null;
    }

    // Check if saved config matches current output state
    function configMatchesCurrent(outputName, savedConfig) {
        const currentOutput = root.state.outputs[outputName];

        if (!currentOutput)
            return false;

        const currentMode = currentOutput.modes?.[currentOutput.current_mode ?? 0];
        const currentScale = currentOutput.logical?.scale ?? 1.0;
        const currentTransform = currentOutput.logical?.transform ?? "Normal";
        const currentVrr = currentOutput.vrr_enabled ?? false;

        if (savedConfig.mode && currentMode) {
            if (savedConfig.mode.width !== currentMode.width || savedConfig.mode.height !== currentMode.height || Math.abs((savedConfig.mode.refresh * 1000) - currentMode.refresh_rate) > 100) {
                return false;
            }
        }

        if (savedConfig.scale !== undefined && Math.abs(savedConfig.scale - currentScale) > 0.01) {
            return false;
        }

        if (savedConfig.transform && savedConfig.transform !== currentTransform) {
            return false;
        }

        if (savedConfig.vrr && savedConfig.vrr.vrr !== currentVrr) {
            return false;
        }

        return true;
    }

    // Apply saved monitor configuration from ShellSettings
    function applySavedMonitorConfig() {
        if (configApplied)
            return;

        const currentOutputs = Object.keys(root.state.outputs);

        if (currentOutputs.length === 0)
            return;

        console.info("Applying saved monitor configuration...");
        configApplied = true;

        applyConfigToOutputs(currentOutputs);
    }

    // Force reload and apply saved monitor configuration
    function reloadMonitorConfig() {
        const currentOutputs = Object.keys(root.state.outputs);

        if (currentOutputs.length === 0) {
            console.info("No outputs available, refreshing...");
            refreshOutputs();
            return;
        }

        console.info("Reloading saved monitor configuration...");
        applyConfigToOutputs(currentOutputs);
    }

    // Internal: Apply saved config to the given outputs
    function applyConfigToOutputs(outputNames) {
        for (const outputName of outputNames) {
            const savedConfig = findSavedConfig(outputName);
            const monitorId = getMonitorIdentifier(root.state.outputs[outputName]);

            if (!savedConfig) {
                console.info(`No saved config for ${monitorId} (${outputName}), skipping`);
                continue;
            }

            // Skip if current config already matches saved config
            if (configMatchesCurrent(outputName, savedConfig)) {
                console.info(`Config for ${monitorId} (${outputName}) already matches, skipping`);
                continue;
            }

            console.info(`Applying config for ${monitorId} (${outputName}):`, JSON.stringify(savedConfig));

            // Apply enabled/disabled state
            if (savedConfig.enabled === false) {
                setOutputOff(outputName);
                continue; // Don't apply other settings if disabled
            }

            // Apply mode (resolution + refresh rate)
            if (savedConfig.mode) {
                setOutputMode(outputName, savedConfig.mode);
            }

            // Apply scale
            if (savedConfig.scale !== undefined) {
                setOutputScale(outputName, savedConfig.scale);
            }

            // Apply transform
            if (savedConfig.transform) {
                setOutputTransform(outputName, savedConfig.transform);
            }

            // Apply position
            if (savedConfig.position && savedConfig.position !== "Automatic") {
                setOutputPosition(outputName, savedConfig.position);
            }

            // Apply VRR
            if (savedConfig.vrr) {
                setOutputVrr(outputName, savedConfig.vrr);
            }
        }
    }

    Connections {
        target: root.state

        function onOutputsChanged() {
            if (!root.configApplied && Object.keys(root.state.outputs).length > 0) {
                applyConfigTimer.restart();
            }
        }
    }

    // Watch for changes to saved monitor config and apply them
    Connections {
        target: ShellSettings

        function onOutputsChanged() {
            if (root.configApplied && Object.keys(root.state.outputs).length > 0) {
                // Re-apply config when settings change (after initial load)
                applySettingsTimer.restart();
            }
        }
    }

    Timer {
        id: applyConfigTimer
        interval: 500
        onTriggered: root.applySavedMonitorConfig()
    }

    Timer {
        id: applySettingsTimer
        interval: 100
        onTriggered: {
            const currentOutputs = Object.keys(root.state.outputs);

            for (const outputName of currentOutputs) {
                const savedConfig = root.findSavedConfig(outputName);
                if (!savedConfig)
                    continue;

                // Skip if current config already matches saved config
                if (root.configMatchesCurrent(outputName, savedConfig))
                    continue;

                const monitorId = root.getMonitorIdentifier(root.state.outputs[outputName]);
                console.info(`Applying updated config for ${monitorId} (${outputName}):`, JSON.stringify(savedConfig));

                if (savedConfig.enabled === false) {
                    root.setOutputOff(outputName);
                    continue;
                }

                if (savedConfig.mode)
                    root.setOutputMode(outputName, savedConfig.mode);

                if (savedConfig.scale !== undefined)
                    root.setOutputScale(outputName, savedConfig.scale);

                if (savedConfig.transform)
                    root.setOutputTransform(outputName, savedConfig.transform);

                if (savedConfig.position && savedConfig.position !== "Automatic")
                    root.setOutputPosition(outputName, savedConfig.position);

                if (savedConfig.vrr)
                    root.setOutputVrr(outputName, savedConfig.vrr);
            }
        }
    }
}
