pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs
import qs.widgets
import qs.services.gsr

SettingsBacker {
    icon: "record-desktop"

    enabled: ShellSettings.settings.gsrEnabled

    content: Item {
        id: menu

        property real cardHeight: 36

        ColumnLayout {
            spacing: 8
            anchors.fill: parent

            StyledText {
                text: "Screen Recording"
                font.pointSize: 9
                font.weight: Font.Medium
                Layout.topMargin: 8
            }

            Separator {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
            }

            SettingsCard {
                title: "Capture"
                summary: "What to record"

                controls: StyledDropdown {
                    color: ShellSettings.colors.active.alternateBase
                    width: 120
                    model: [
                        {
                            label: "Screen",
                            value: "screen"
                        },
                        {
                            label: "Portal",
                            value: "portal"
                        }
                    ]

                    currentValue: GpuScreenRecord.config.window
                    onSelected: value => GpuScreenRecord.config.window = value

                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        rightMargin: 12
                    }
                }

                Layout.fillWidth: true
                Layout.preferredHeight: menu.cardHeight
            }

            SettingsCard {
                title: "FPS"
                summary: "Frames per second"

                controls: StyledDropdown {
                    color: ShellSettings.colors.active.alternateBase
                    width: 80
                    model: ["30", "60", "120", "144", "165", "240"].map(x => {
                        return {
                            label: x,
                            value: x
                        };
                    })

                    currentValue: GpuScreenRecord.config.fps.toString()
                    onSelected: value => GpuScreenRecord.config.fps = parseInt(value)

                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        rightMargin: 12
                    }
                }

                Layout.fillWidth: true
                Layout.preferredHeight: menu.cardHeight
            }

            SettingsCard {
                title: "Show Cursor"
                summary: "Include cursor in recording"

                controls: ToggleSwitch {
                    checked: GpuScreenRecord.config.cursor

                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        rightMargin: 12
                    }

                    onCheckedChanged: {
                        if (GpuScreenRecord.config.cursor !== checked) {
                            GpuScreenRecord.config.cursor = checked;
                        }
                    }
                }

                Layout.fillWidth: true
                Layout.preferredHeight: menu.cardHeight
            }

            SettingsCard {
                title: "Codec"
                summary: "Video codec for encoding"

                controls: StyledDropdown {
                    color: ShellSettings.colors.active.alternateBase
                    width: 100
                    model: [
                        {
                            label: "H.264",
                            value: "h264"
                        },
                        {
                            label: "HEVC",
                            value: "hevc"
                        },
                        {
                            label: "AV1",
                            value: "av1"
                        },
                        {
                            label: "VP8",
                            value: "vp8"
                        },
                        {
                            label: "VP9",
                            value: "vp9"
                        },
                        {
                            label: "HEVC HDR",
                            value: "hevc_hdr"
                        },
                        {
                            label: "AV1 HDR",
                            value: "av1_hdr"
                        },
                        {
                            label: "HEVC 10bit",
                            value: "hevc_10bit"
                        },
                        {
                            label: "AV1 10bit",
                            value: "av1_10bit"
                        }
                    ]

                    currentValue: GpuScreenRecord.config.codec
                    onSelected: value => GpuScreenRecord.config.codec = value

                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        rightMargin: 12
                    }
                }

                Layout.fillWidth: true
                Layout.preferredHeight: menu.cardHeight
            }

            SettingsCard {
                title: "Quality"
                summary: "Encoding quality preset"

                controls: StyledDropdown {
                    color: ShellSettings.colors.active.alternateBase
                    width: 100
                    model: [
                        {
                            label: "Very High",
                            value: "very_high"
                        },
                        {
                            label: "High",
                            value: "high"
                        },
                        {
                            label: "Medium",
                            value: "medium"
                        },
                        {
                            label: "Low",
                            value: "low"
                        }
                    ]

                    currentValue: GpuScreenRecord.config.quality
                    onSelected: value => GpuScreenRecord.config.quality = value

                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        rightMargin: 12
                    }
                }

                Layout.fillWidth: true
                Layout.preferredHeight: menu.cardHeight
            }

            SettingsCard {
                title: "Container"
                summary: "Output file format"

                controls: StyledDropdown {
                    color: ShellSettings.colors.active.alternateBase
                    width: 80
                    model: [
                        {
                            label: "MP4",
                            value: "mp4"
                        },
                        {
                            label: "MKV",
                            value: "mkv"
                        },
                        {
                            label: "FLV",
                            value: "flv"
                        },
                        {
                            label: "WebM",
                            value: "webm"
                        }
                    ]

                    currentValue: GpuScreenRecord.config.containerFormat
                    onSelected: value => GpuScreenRecord.config.containerFormat = value

                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        rightMargin: 12
                    }
                }

                Layout.fillWidth: true
                Layout.preferredHeight: menu.cardHeight
            }

            SettingsCard {
                title: "Buffer Size"
                summary: "Replay buffer duration in seconds (0 = recording mode)"

                controls: StyledDropdown {
                    color: ShellSettings.colors.active.alternateBase
                    width: 100
                    model: [
                        {
                            label: "Disabled",
                            value: "0"
                        },
                        {
                            label: "15 sec",
                            value: "15"
                        },
                        {
                            label: "30 sec",
                            value: "30"
                        },
                        {
                            label: "60 sec",
                            value: "60"
                        },
                        {
                            label: "120 sec",
                            value: "120"
                        },
                        {
                            label: "300 sec",
                            value: "300"
                        }
                    ]

                    currentValue: GpuScreenRecord.config.replayBufferSize.toString()
                    onSelected: value => GpuScreenRecord.config.replayBufferSize = parseInt(value)

                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        rightMargin: 12
                    }
                }

                Layout.fillWidth: true
                Layout.preferredHeight: menu.cardHeight
            }

            SettingsCard {
                title: "Storage"
                summary: "Where to keep replay buffer"

                controls: StyledDropdown {
                    color: ShellSettings.colors.active.alternateBase
                    width: 80
                    model: [
                        {
                            label: "RAM",
                            value: "ram"
                        },
                        {
                            label: "Disk",
                            value: "disk"
                        }
                    ]

                    currentValue: GpuScreenRecord.config.replayStorage
                    onSelected: value => GpuScreenRecord.config.replayStorage = value

                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        rightMargin: 12
                    }
                }

                Layout.fillWidth: true
                Layout.preferredHeight: menu.cardHeight
            }

            SettingsCard {
                title: "Audio Input"
                summary: "Audio source(s), comma-separated"

                controls: StyledTextInput {
                    text: GpuScreenRecord.config.audioInput
                    width: 140
                    placeholderText: "e.g., default_input"

                    onAccepted: GpuScreenRecord.config.audioInput = text

                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        rightMargin: 12
                    }
                }

                Layout.fillWidth: true
                Layout.preferredHeight: menu.cardHeight
            }

            SettingsCard {
                title: "Audio Codec"
                summary: "Audio encoding format"

                controls: StyledDropdown {
                    color: ShellSettings.colors.active.alternateBase
                    width: 80
                    model: [
                        {
                            label: "Opus",
                            value: "opus"
                        },
                        {
                            label: "AAC",
                            value: "aac"
                        },
                        {
                            label: "FLAC",
                            value: "flac"
                        }
                    ]

                    currentValue: GpuScreenRecord.config.audioCodec
                    onSelected: value => GpuScreenRecord.config.audioCodec = value

                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        rightMargin: 12
                    }
                }

                Layout.fillWidth: true
                Layout.preferredHeight: menu.cardHeight
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }
}
