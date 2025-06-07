pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs
import qs.widgets
import qs.services.niri

StyledRectangle {
    id: root

    property string selectedOutput: ""
    property var outputs: ({})
    property var selectedOutputData: outputs[selectedOutput] ?? null

    signal saveConfig

    visible: selectedOutput !== ""
    color: ShellSettings.colors.active.base

    Flickable {
        anchors.fill: parent
        anchors.margins: 12
        clip: true
        contentHeight: detailsContent.implicitHeight
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: detailsContent
            width: parent.width
            spacing: 12

            // Monitor Name Header with Enable Toggle
            RowLayout {
                spacing: 8
                Layout.fillWidth: true

                IconImage {
                    source: Quickshell.iconPath("video-display")
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                }

                ColumnLayout {
                    spacing: 2

                    StyledText {
                        text: root.selectedOutput
                        font.pointSize: 13
                    }

                    StyledText {
                        color: ShellSettings.colors.active.windowText.darker(1.5)
                        font.pointSize: 9
                        text: {
                            const data = root.selectedOutputData;
                            if (!data)
                                return "";
                            return `${data.make ?? "Unknown"} ${data.model ?? ""}`.trim();
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                ToggleSwitch {
                    id: enabledSwitch
                    checked: true
                    onClicked: {
                        if (checked) {
                            Niri.setOutputOn(root.selectedOutput);
                        } else {
                            Niri.setOutputOff(root.selectedOutput);
                        }
                        root.saveConfig();
                    }
                }
            }

            Separator {
                color: ShellSettings.colors.active.light
                Layout.fillWidth: true
            }

            // Resolution Selection Row
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                StyledText {
                    text: "Resolution"
                    color: ShellSettings.colors.active.windowText.darker(1.5)
                    font.pointSize: 9
                }

                Item {
                    Layout.fillWidth: true
                }

                StyledDropdown {
                    id: resolutionDropdown
                    Layout.preferredWidth: 140

                    model: {
                        const data = root.selectedOutputData;
                        if (!data?.modes)
                            return [];

                        const resMap = new Map();
                        for (const mode of data.modes) {
                            const key = `${mode.width}x${mode.height}`;
                            if (!resMap.has(key) || mode.refresh_rate > resMap.get(key).refresh_rate) {
                                resMap.set(key, mode);
                            }
                        }
                        return Array.from(resMap.values()).map(m => ({
                            value: `${m.width}x${m.height}`,
                            label: `${m.width}x${m.height}`,
                            width: m.width,
                            height: m.height,
                            refresh_rate: m.refresh_rate
                        }));
                    }

                    currentValue: {
                        const data = root.selectedOutputData;
                        const currentMode = data?.modes?.[data?.current_mode ?? 0];
                        if (!currentMode)
                            return "";
                        return `${currentMode.width}x${currentMode.height}`;
                    }

                    onSelected: value => {
                        const item = model.find(m => m.value === value);
                        if (item) {
                            Niri.setOutputMode(root.selectedOutput, {
                                width: item.width,
                                height: item.height,
                                refresh: item.refresh_rate / 1000.0
                            });
                            root.saveConfig();
                        }
                    }
                }
            }

            // Refresh Rate Selection Row
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                StyledText {
                    text: "Refresh Rate"
                    color: ShellSettings.colors.active.windowText.darker(1.5)
                    font.pointSize: 9
                }

                Item {
                    Layout.fillWidth: true
                }

                StyledDropdown {
                    id: refreshDropdown
                    Layout.preferredWidth: 140

                    model: {
                        const data = root.selectedOutputData;
                        if (!data?.modes)
                            return [];

                        const currentMode = data.modes[data.current_mode ?? 0];
                        if (!currentMode)
                            return [];

                        return data.modes
                            .filter(m => m.width === currentMode.width && m.height === currentMode.height)
                            .map(m => ({
                                value: String(m.refresh_rate),
                                label: `${(m.refresh_rate / 1000).toFixed(1)} Hz`,
                                width: m.width,
                                height: m.height,
                                refresh_rate: m.refresh_rate
                            }));
                    }

                    currentValue: {
                        const data = root.selectedOutputData;
                        const currentMode = data?.modes?.[data?.current_mode ?? 0];
                        if (!currentMode)
                            return "";
                        return String(currentMode.refresh_rate);
                    }

                    onSelected: value => {
                        const item = model.find(m => m.value === value);
                        if (item) {
                            Niri.setOutputMode(root.selectedOutput, {
                                width: item.width,
                                height: item.height,
                                refresh: item.refresh_rate / 1000.0
                            });
                            root.saveConfig();
                        }
                    }
                }
            }

            // Scale Selection Row
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                StyledText {
                    text: "Scale"
                    color: ShellSettings.colors.active.windowText.darker(1.5)
                    font.pointSize: 9
                }

                Item {
                    Layout.fillWidth: true
                }

                StyledDropdown {
                    id: scaleDropdown
                    Layout.preferredWidth: 140

                    model: [
                        { value: "0.5", label: "50%" },
                        { value: "0.75", label: "75%" },
                        { value: "1.0", label: "100%" },
                        { value: "1.25", label: "125%" },
                        { value: "1.5", label: "150%" },
                        { value: "1.75", label: "175%" },
                        { value: "2.0", label: "200%" },
                        { value: "2.5", label: "250%" },
                        { value: "3.0", label: "300%" }
                    ]

                    currentValue: {
                        const data = root.selectedOutputData;
                        const scale = data?.logical?.scale ?? 1.0;
                        // Normalize to match model values (e.g., 1 -> "1.0", 1.5 -> "1.5")
                        const str = String(scale);
                        return str.includes('.') ? str : str + ".0";
                    }

                    onSelected: value => {
                        Niri.setOutputScale(root.selectedOutput, parseFloat(value));
                        root.saveConfig();
                    }
                }
            }

            // Rotation Selection Row
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                StyledText {
                    text: "Rotation"
                    color: ShellSettings.colors.active.windowText.darker(1.5)
                    font.pointSize: 9
                }

                Item {
                    Layout.fillWidth: true
                }

                StyledDropdown {
                    id: rotationDropdown
                    Layout.preferredWidth: 140

                    model: [
                        { value: "Normal", label: "0°" },
                        { value: "_90", label: "90°" },
                        { value: "_180", label: "180°" },
                        { value: "_270", label: "270°" },
                        { value: "Flipped", label: "Flip H" },
                        { value: "Flipped180", label: "Flip V" }
                    ]

                    currentValue: {
                        const data = root.selectedOutputData;
                        return data?.logical?.transform ?? "Normal";
                    }

                    onSelected: value => {
                        Niri.setOutputTransform(root.selectedOutput, value);
                        root.saveConfig();
                    }
                }
            }
            Separator {
                visible: root.selectedOutputData?.vrr_supported ?? false
                color: ShellSettings.colors.active.light
                Layout.fillWidth: true
            }

            // VRR Toggle
            RowLayout {
                visible: root.selectedOutputData?.vrr_supported ?? false
                spacing: 8
                Layout.fillWidth: true

                StyledText {
                    text: "Variable Refresh Rate (VRR)"
                    font.pointSize: 9
                    color: ShellSettings.colors.active.windowText.darker(1.5)
                }

                Item {
                    Layout.fillWidth: true
                }

                ToggleSwitch {
                    id: vrrSwitch
                    checked: root.selectedOutputData?.vrr_enabled ?? false
                    onClicked: {
                        Niri.setOutputVrr(root.selectedOutput, {
                            vrr: checked,
                            on_demand: false
                        });
                        root.saveConfig();
                    }
                }
            }

            Separator {
                color: ShellSettings.colors.active.light
                Layout.fillWidth: true
            }

            // Monitor Info
            StyledText {
                text: "Monitor Info"
                font.pointSize: 9
                color: ShellSettings.colors.active.windowText.darker(1.5)
            }

            GridLayout {
                columns: 2
                columnSpacing: 16
                rowSpacing: 4
                Layout.fillWidth: true

                StyledText {
                    text: "Position"
                    font.pointSize: 8
                    color: ShellSettings.colors.active.windowText.darker(1.8)
                }

                StyledText {
                    font.pointSize: 8
                    text: {
                        const data = root.selectedOutputData;
                        if (!data?.logical)
                            return "0, 0";
                        return `${data.logical.x}, ${data.logical.y}`;
                    }
                }

                StyledText {
                    text: "Physical Size"
                    font.pointSize: 8
                    color: ShellSettings.colors.active.windowText.darker(1.8)
                }

                StyledText {
                    font.pointSize: 8
                    text: {
                        const data = root.selectedOutputData;
                        if (!data?.physical_size)
                            return "Unknown";
                        return `${data.physical_size[0]} x ${data.physical_size[1]} mm`;
                    }
                }

                StyledText {
                    text: "Serial"
                    font.pointSize: 8
                    color: ShellSettings.colors.active.windowText.darker(1.8)
                }

                StyledText {
                    text: root.selectedOutputData?.serial ?? "Unknown"
                    font.pointSize: 8
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }
        }
    }
}
