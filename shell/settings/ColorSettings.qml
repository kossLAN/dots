pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import QtQuick.Dialogs as Dialogs
import ".."

ColumnLayout {
    id: root
    spacing: 20
    Layout.fillWidth: true
    Layout.fillHeight: true

    property var colorFields: [
        ({ key: "background", label: "Background", description: "Glass backdrop for popups" }),
        ({ key: "foreground", label: "Foreground", description: "Primary text and icons" }),
        ({ key: "foregroundDim", label: "Foreground Dim", description: "Muted text and subtitles" }),
        ({ key: "accent", label: "Accent", description: "Interactive accents" }),
        ({ key: "highlight", label: "Highlight", description: "Focus + hover states" }),
        ({ key: "trim", label: "Trim", description: "Outline and separators" }),
        ({ key: "border", label: "Border", description: "Primary borders" }),
        ({ key: "borderSubtle", label: "Border Subtle", description: "Low-contrast borders" })
    ]

    property string pendingPresetName: ""
    property string activePresetId: ""

    function componentToHex(value) {
        return Math.round(Math.max(0, Math.min(1, value)) * 255).toString(16).padStart(2, "0").toUpperCase();
    }

    function colorAsHex(key) {
        const value = ShellSettings.colors[key];
        if (!value) {
            return "#000000FF";
        }
        return `#${componentToHex(value.r)}${componentToHex(value.g)}${componentToHex(value.b)}${componentToHex(value.a)}`;
    }

    function parseHex(hex) {
        if (!hex) {
            return null;
        }
        let normalized = hex.trim();
        if (!normalized.startsWith("#")) {
            normalized = `#${normalized}`;
        }
        if (normalized.length === 7) {
            normalized += "FF";
        }
        if (!/^#[0-9a-fA-F]{8}$/.test(normalized)) {
            return null;
        }
        const r = parseInt(normalized.slice(1, 3), 16) / 255;
        const g = parseInt(normalized.slice(3, 5), 16) / 255;
        const b = parseInt(normalized.slice(5, 7), 16) / 255;
        const a = parseInt(normalized.slice(7, 9), 16) / 255;
        return Qt.rgba(r, g, b, a);
    }

    function updateColorFromHex(key, hex) {
        const value = parseHex(hex);
        if (!value) {
            return;
        }
        ShellSettings.colors[key] = value;
        activePresetId = "";
    }

    function openColorDialog(key) {
        colorDialog.targetKey = key;
        colorDialog.color = ShellSettings.colors[key];
        colorDialog.open();
    }

    function snapshotColorsAsHex() {
        const result = {};
        for (const item of colorFields) {
            result[item.key] = colorAsHex(item.key);
        }
        return result;
    }

    function slugify(name) {
        const base = name.toLowerCase().replace(/[^a-z0-9]+/g, "_").replace(/^_+|_+$/g, "");
        return base.length ? base : "preset";
    }

    function uniquePresetId(name) {
        const existing = (ShellSettings.colorPresets || []).map(p => p.id);
        const base = slugify(name);
        let candidate = base;
        let i = 2;
        while (existing.indexOf(candidate) !== -1) {
            candidate = `${base}_${i}`;
            i += 1;
        }
        return candidate;
    }

    function saveCurrentPreset() {
        const label = pendingPresetName.trim();
        if (!label.length) {
            return;
        }
        const preset = {
            id: uniquePresetId(label),
            name: label,
            description: `Snapshot saved ${new Date().toLocaleString()}`,
            colors: snapshotColorsAsHex()
        };
        const list = ShellSettings.colorPresets || [];
        ShellSettings.colorPresets = list.filter(p => p.id !== preset.id).concat([preset]);
        pendingPresetName = "";
        activePresetId = preset.id;
    }

    function palettesMatch(reference, candidate) {
        if (!reference || !candidate) {
            return false;
        }
        for (const item of colorFields) {
            const key = item.key;
            if ((reference[key] || "").toUpperCase() !== (candidate[key] || "").toUpperCase()) {
                return false;
            }
        }
        return true;
    }

    function detectMatchingPreset() {
        const snapshot = snapshotColorsAsHex();
        for (const preset of ShellSettings.colorPresets || []) {
            if (palettesMatch(preset.colors, snapshot)) {
                return preset.id;
            }
        }
        return "";
    }

    function applyPreset(preset) {
        if (!preset || !preset.colors) {
            return;
        }
        for (const item of colorFields) {
            if (preset.colors[item.key]) {
                ShellSettings.colors[item.key] = preset.colors[item.key];
            }
        }
        activePresetId = preset.id || "";
    }

    Dialogs.ColorDialog {
        id: colorDialog
        title: "Choose color"
        property string targetKey: ""
        onAccepted: {
            if (!targetKey.length) {
                return;
            }
            ShellSettings.colors[targetKey] = color;
            activePresetId = "";
        }
    }

    Component.onCompleted: activePresetId = detectMatchingPreset()

    Connections {
        target: ShellSettings.colors

        function onBackgroundChanged() { activePresetId = detectMatchingPreset(); }
        function onForegroundChanged() { activePresetId = detectMatchingPreset(); }
        function onForegroundDimChanged() { activePresetId = detectMatchingPreset(); }
        function onAccentChanged() { activePresetId = detectMatchingPreset(); }
        function onHighlightChanged() { activePresetId = detectMatchingPreset(); }
        function onTrimChanged() { activePresetId = detectMatchingPreset(); }
        function onBorderChanged() { activePresetId = detectMatchingPreset(); }
        function onBorderSubtleChanged() { activePresetId = detectMatchingPreset(); }
    }

    Connections {
        target: ShellSettings
        function onColorPresetsChanged() { activePresetId = detectMatchingPreset(); }
    }

    Controls.GroupBox {
        title: "Presets"
        Layout.fillWidth: true

        ColumnLayout {
            spacing: 12
            Layout.fillWidth: true

            Flow {
                Layout.fillWidth: true
                spacing: 10

                Repeater {
                    model: ShellSettings.colorPresets || []

                    Controls.Button {
                        required property var modelData
                        text: modelData.name
                        checkable: true
                        checked: root.activePresetId === modelData.id
                        onClicked: applyPreset(modelData)
                        Controls.ToolTip.visible: hovered
                        Controls.ToolTip.delay: 250
                        Controls.ToolTip.text: modelData.description || ""
                    }
                }
            }

            RowLayout {
                spacing: 12
                Layout.fillWidth: true

                Controls.TextField {
                    Layout.fillWidth: true
                    placeholderText: "Preset name"
                    text: root.pendingPresetName
                    onTextChanged: root.pendingPresetName = text
                }

                Controls.Button {
                    text: "Save current"
                    enabled: root.pendingPresetName.trim().length > 0
                    onClicked: saveCurrentPreset()
                }
            }
        }
    }

    Controls.ScrollView {
        Layout.fillWidth: true
        Layout.fillHeight: true

        ColumnLayout {
            id: colorList
            spacing: 12
            width: parent.width

            Repeater {
                model: root.colorFields

                Rectangle {
                    required property var modelData
                    Layout.fillWidth: true
                    implicitHeight: 84
                    radius: 16
                    color: Qt.rgba(1, 1, 1, 0.04)

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 16

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                text: modelData.label
                                font.pixelSize: 16
                                color: ShellSettings.colors.foreground
                                font.bold: true
                            }

                            Text {
                                text: modelData.description
                                font.pixelSize: 12
                                color: ShellSettings.colors.foregroundDim
                                elide: Text.ElideRight
                            }
                        }

                        Rectangle {
                            width: 56
                            height: 56
                            radius: 12
                            color: ShellSettings.colors[modelData.key]
                            border.color: ShellSettings.colors.border
                            border.width: 1
                        }

                        Controls.TextField {
                            Layout.preferredWidth: 140
                            text: root.colorAsHex(modelData.key)
                            validator: RegularExpressionValidator { regularExpression: /#?[0-9a-fA-F]{8}/ }
                            inputMethodHints: Qt.ImhPreferUppercase
                            onEditingFinished: root.updateColorFromHex(modelData.key, text)
                        }

                        Controls.Button {
                            text: "Pick"
                            onClicked: root.openColorDialog(modelData.key)
                        }
                    }
                }
            }
        }
    }
}
