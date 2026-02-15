pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland

Item {
    id: root

    property var nameFilters: []
    property bool folderMode: false
    property url selectedFile: ""
    property string homePath: Quickshell.env("HOME")
    property url currentFolder: `file://${root.homePath}`
    property bool showHidden: false

    signal accepted
    signal rejected

    visible: false

    function open() {
        root.visible = true;
        root._selectedPath = "";
        root._selectedName = "";
    }

    function close() {
        root.visible = false;
    }

    property var _parsedFilters: root._parseFilters(root.nameFilters)
    property int _activeFilterIndex: {
        for (let i = 0; i < root._parsedFilters.length; i++) {
            if (root._parsedFilters[i].patterns.length === 1 && root._parsedFilters[i].patterns[0] === "*")
                return i;
        }

        return 0;
    }
    property var _history: []
    property string _selectedPath: ""
    property string _selectedName: ""
    property bool _selectedIsDir: false
    property int _sortField: 0
    property bool _sortReversed: false

    property var _activePatterns: {
        if (root._activeFilterIndex >= 0 && root._activeFilterIndex < root._parsedFilters.length)
            return root._parsedFilters[root._activeFilterIndex].patterns;

        return ["*"];
    }

    function _parseFilters(filters: list<string>): list<var> {
        if (!filters || filters.length === 0)
            return [
                {
                    label: "All files",
                    patterns: ["*"]
                }
            ];

        return filters.map(f => {
            const match = f.match(/^(.*?)\s*\((.*)\)\s*$/);

            if (match)
                return {
                    label: match[1].trim(),
                    patterns: match[2].trim().split(/\s+/)
                };

            return {
                label: f,
                patterns: ["*"]
            };
        });
    }

    function _navigateTo(folderUrl: url) {
        const hist = root._history.slice();

        hist.push(root.currentFolder);

        root._history = hist;
        root.currentFolder = folderUrl;
        root._selectedPath = "";
        root._selectedName = "";
    }

    function _navigateUp() {
        let path = root.currentFolder.toString();

        if (path.endsWith("/") && path !== "file:///")
            path = path.slice(0, -1);

        const lastSlash = path.lastIndexOf("/");

        if (lastSlash >= 7)
            root._navigateTo(path.substring(0, lastSlash + 1));
    }

    function _navigateBack() {
        if (root._history.length === 0)
            return;

        const hist = root._history.slice();

        root.currentFolder = hist.pop();
        root._history = hist;
        root._selectedPath = "";
        root._selectedName = "";
    }

    function _accept() {
        if (root.folderMode) {
            root.selectedFile = root._selectedPath !== "" && root._selectedIsDir ? `file://${root._selectedPath}` : root.currentFolder;
            root.close();
            root.accepted();
        } else {
            if (root._selectedPath === "")
                return;

            if (root._selectedIsDir) {
                root._navigateTo(`file://${root._selectedPath}`);
                return;
            }

            root.selectedFile = `file://${root._selectedPath}`;
            root.close();
            root.accepted();
        }
    }

    function _cancel() {
        root.close();
        root.rejected();
    }

    function _displayPath(): string {
        let path = root.currentFolder.toString();

        if (path.startsWith("file://"))
            path = path.substring(7);

        if (path === "")
            path = "/";

        return path;
    }

    function _formatSize(bytes: double): string {
        if (bytes < 1024)
            return bytes + " B";

        if (bytes < 1048576)
            return (bytes / 1024).toFixed(1) + " KB";

        if (bytes < 1073741824)
            return (bytes / 1048576).toFixed(1) + " MB";

        return (bytes / 1073741824).toFixed(1) + " GB";
    }

    LazyLoader {
        active: root.visible

        PanelWindow {
            id: panel
            visible: true
            color: "transparent"
            exclusiveZone: 0

            WlrLayershell.namespace: "shell:filepicker"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            mask: Region {
                item: filePicker
            }

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            Item {
                anchors.fill: parent

                Shortcut {
                    sequences: [StandardKey.Cancel]
                    onActivated: root._cancel()
                }

                FilePickerDialog {
                    id: filePicker
                    picker: root
                    width: Math.min(panel.width - 40, 800)
                    height: Math.min(panel.height - 40, 520)
                    x: (panel.width / 2) - (filePicker.width / 2)
                    y: (panel.height / 2) - (filePicker.height / 2)

                    DragHandler {
                        id: handler
                        target: filePicker

                        xAxis.minimum: 0
                        xAxis.maximum: panel.width - filePicker.width
                        yAxis.minimum: 0
                        yAxis.maximum: panel.height - filePicker.height
                    }
                }
            }
        }
    }
}
