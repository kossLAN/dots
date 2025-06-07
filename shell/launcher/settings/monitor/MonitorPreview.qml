pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs
import qs.widgets

Item {
    id: root

    property var outputs: ({})
    property var outputList: []
    property string selectedOutput: ""

    // Calculate bounds for monitor layout visualization
    property real minX: {
        let min = Infinity;
        for (const name of outputList) {
            const output = outputs[name];
            if (output?.logical?.x !== undefined && output.logical.x < min)
                min = output.logical.x;
        }
        return min === Infinity ? 0 : min;
    }

    property real maxX: {
        let max = -Infinity;
        for (const name of outputList) {
            const output = outputs[name];
            if (output?.logical) {
                const right = output.logical.x + output.logical.width;
                if (right > max)
                    max = right;
            }
        }
        return max === -Infinity ? 0 : max;
    }

    property real minY: {
        let min = Infinity;
        for (const name of outputList) {
            const output = outputs[name];
            if (output?.logical?.y !== undefined && output.logical.y < min)
                min = output.logical.y;
        }
        return min === Infinity ? 0 : min;
    }

    property real maxY: {
        let max = -Infinity;
        for (const name of outputList) {
            const output = outputs[name];
            if (output?.logical) {
                const bottom = output.logical.y + output.logical.height;
                if (bottom > max)
                    max = bottom;
            }
        }
        return max === -Infinity ? 0 : max;
    }

    property real totalWidth: maxX - minX
    property real totalHeight: maxY - minY

    Item {
        id: previewArea
        anchors.fill: parent
        anchors.margins: 16

        property real previewScale: {
            if (root.totalWidth === 0 || root.totalHeight === 0)
                return 1;
            const scaleX = width / root.totalWidth;
            const scaleY = height / root.totalHeight;
            return Math.min(scaleX, scaleY) * 0.9;
        }

        property real offsetX: (width - root.totalWidth * previewScale) / 2 - root.minX * previewScale
        property real offsetY: (height - root.totalHeight * previewScale) / 2 - root.minY * previewScale

        Repeater {
            model: root.outputList

            Rectangle {
                id: monitorRect

                required property string modelData
                property var output: root.outputs[modelData] ?? null
                property bool isSelected: root.selectedOutput === modelData

                x: output?.logical ? previewArea.offsetX + output.logical.x * previewArea.previewScale : 0
                y: output?.logical ? previewArea.offsetY + output.logical.y * previewArea.previewScale : 0
                width: output?.logical ? output.logical.width * previewArea.previewScale : 100
                height: output?.logical ? output.logical.height * previewArea.previewScale : 60

                color: isSelected ? ShellSettings.colors.active.highlight : ShellSettings.colors.active.button
                border.width: 2
                border.color: isSelected ? ShellSettings.colors.active.highlight.lighter(1.3) : ShellSettings.colors.active.light
                radius: 12

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.selectedOutput = monitorRect.modelData
                    cursorShape: Qt.PointingHandCursor
                }

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 2

                    StyledText {
                        text: monitorRect.modelData
                        color: monitorRect.isSelected ? ShellSettings.colors.active.highlightedText : ShellSettings.colors.active.buttonText
                        font.pointSize: 9
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledText {
                        color: monitorRect.isSelected ? ShellSettings.colors.active.highlightedText.darker(1.2) : ShellSettings.colors.active.buttonText.darker(1.3)
                        font.pointSize: 9
                        text: {
                            if (!monitorRect.output?.current_mode && monitorRect.output?.modes) {
                                const mode = monitorRect.output.modes[0];
                                return mode ? `${mode.width}x${mode.height}` : "";
                            }
                            const mode = monitorRect.output?.modes?.[monitorRect.output.current_mode];
                            return mode ? `${mode.width}x${mode.height}` : "";
                        }
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
        }
    }

    // Empty state
    ColumnLayout {
        anchors.centerIn: parent
        spacing: 8
        visible: root.outputList.length === 0

        IconImage {
            source: Quickshell.iconPath("video-display")
            opacity: 0.5
            Layout.preferredWidth: 48
            Layout.preferredHeight: 48
            Layout.alignment: Qt.AlignHCenter
        }

        StyledText {
            text: "No displays detected"
            color: ShellSettings.colors.active.windowText.darker(1.5)
            font.pointSize: 9
            Layout.alignment: Qt.AlignHCenter
        }
    }
}
