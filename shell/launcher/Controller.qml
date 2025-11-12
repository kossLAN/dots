pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import qs
import qs.widgets

Singleton {
    PersistentProperties {
        id: persist
        property bool launcherOpen: false
    }

    IpcHandler {
        target: "launcher"

        function open(): void {
            persist.launcherOpen = true;
        }

        function close(): void {
            persist.launcherOpen = false;
        }

        function toggle(): void {
            persist.launcherOpen = !persist.launcherOpen;
        }
    }

    LazyLoader {
        id: loader
        // activeAsync: persist.launcherOpen
        active: persist.launcherOpen

        PanelWindow {
            color: "transparent"
            exclusiveZone: 0
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            // WlrLayershell.namespace: "shell:launcher"

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            WrapperRectangle {
                clip: true
                radius: 12
                color: ShellSettings.colors.surface_translucent
                margin: 6

                border {
                    width: 1
                    color: ShellSettings.colors.active_translucent
                }

                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: parent.top
                    topMargin: screen.height / 3 
                }

                ColumnLayout {
                    id: column
                    anchors.centerIn: parent

                    StyledRectangle {
                        id: searchContainer
                        implicitHeight: searchbox.implicitHeight + 15
                        radius: 6

                        // Width is largely determined by size of the searchContainer
                        Layout.preferredWidth: 500

                        RowLayout {
                            id: searchbox
                            anchors.fill: parent
                            anchors.margins: 5

                            TextInput {
                                id: search
                                color: ShellSettings.colors.highlight
                                Layout.fillWidth: true

                                focus: true
                                Keys.forwardTo: [list]
                                Keys.onEscapePressed: persist.launcherOpen = false

                                Keys.onPressed: event => {
                                    if (event.modifiers & Qt.ControlModifier) {
                                        if (event.key == Qt.Key_J) {
                                            list.currentIndex = list.currentIndex == list.count - 1 ? 0 : list.currentIndex + 1;
                                            event.accepted = true;
                                        } else if (event.key == Qt.Key_K) {
                                            list.currentIndex = list.currentIndex == 0 ? list.count - 1 : list.currentIndex - 1;
                                            event.accepted = true;
                                        }
                                    }
                                }

                                onAccepted: {
                                    if (list.currentItem) {
                                        list.currentItem.clicked(null);
                                    }
                                }

                                onTextChanged: {
                                    list.currentIndex = 0;
                                }
                            }
                        }
                    }

                    ListView {
                        id: list
                        visible: Layout.preferredHeight > 1
                        clip: true
                        cacheBuffer: 0 // works around QTBUG-131106
                        //reuseItems: true

                        Layout.fillWidth: true
                        Layout.preferredHeight: Math.min(matchesLength * delegateHeight, 500)

                        Behavior on Layout.preferredHeight {
                            NumberAnimation {
                                duration: 200
                                easing.type: Easing.OutCubic
                            }
                        }

                        property var matchesLength: model.values.length

                        model: ScriptModel {
                            values: {
                                const stxt = search.text.toLowerCase();

                                if (stxt === '')
                                    return [];

                                return DesktopEntries.applications.values.map(object => {
                                    // const stxt = search.text.toLowerCase();

                                    const ntxt = object.name.toLowerCase();
                                    let si = 0;
                                    let ni = 0;

                                    let matches = [];
                                    let startMatch = -1;

                                    for (let si = 0; si != stxt.length; ++si) {
                                        const sc = stxt[si];

                                        while (true) {
                                            // Drop any entries with letters that don't exist in order
                                            if (ni == ntxt.length)
                                                return null;

                                            const nc = ntxt[ni++];

                                            if (nc == sc) {
                                                if (startMatch == -1)
                                                    startMatch = ni;
                                                break;
                                            } else {
                                                if (startMatch != -1) {
                                                    matches.push({
                                                        index: startMatch,
                                                        length: ni - startMatch
                                                    });

                                                    startMatch = -1;
                                                }
                                            }
                                        }
                                    }

                                    if (startMatch != -1) {
                                        matches.push({
                                            index: startMatch,
                                            length: ni - startMatch + 1
                                        });
                                    }

                                    return {
                                        object: object,
                                        matches: matches
                                    };
                                }).filter(entry => entry !== null).sort((a, b) => {
                                    let ai = 0;
                                    let bi = 0;
                                    let s = 0;

                                    while (ai != a.matches.length && bi != b.matches.length) {
                                        const am = a.matches[ai];
                                        const bm = b.matches[bi];

                                        s = bm.length - am.length;
                                        if (s != 0)
                                            return s;

                                        s = am.index - bm.index;
                                        if (s != 0)
                                            return s;

                                        ++ai;
                                        ++bi;
                                    }

                                    s = a.matches.length - b.matches.length;
                                    if (s != 0)
                                        return s;

                                    s = a.object.name.length - b.object.name.length;
                                    if (s != 0)
                                        return s;

                                    return a.object.name.localeCompare(b.object.name);
                                }).map(entry => entry.object);
                            }

                            onValuesChanged: list.currentIndex = 0
                        }

                        add: Transition {
                            NumberAnimation {
                                property: "opacity"
                                from: 0
                                to: 1
                                duration: 100
                            }
                        }

                        displaced: Transition {
                            NumberAnimation {
                                property: "y"
                                duration: 200
                                easing.type: Easing.OutCubic
                            }
                            NumberAnimation {
                                property: "opacity"
                                to: 1
                                duration: 100
                            }
                        }

                        move: Transition {
                            NumberAnimation {
                                property: "y"
                                duration: 200
                                easing.type: Easing.OutCubic
                            }
                            NumberAnimation {
                                property: "opacity"
                                to: 1
                                duration: 100
                            }
                        }

                        remove: Transition {
                            NumberAnimation {
                                property: "y"
                                duration: 200
                                easing.type: Easing.OutCubic
                            }
                            NumberAnimation {
                                property: "opacity"
                                to: 0
                                duration: 100
                            }
                        }

                        highlight: Rectangle {
                            radius: 6
                            color: ShellSettings.colors.active_translucent
                        }

                        keyNavigationEnabled: true
                        keyNavigationWraps: true
                        highlightMoveVelocity: -1
                        highlightMoveDuration: 100
                        preferredHighlightBegin: list.topMargin
                        preferredHighlightEnd: list.height - list.bottomMargin
                        highlightRangeMode: ListView.ApplyRange
                        snapMode: ListView.SnapToItem

                        readonly property real delegateHeight: 44

                        delegate: MouseArea {
                            id: entryMouseArea
                            required property DesktopEntry modelData

                            implicitHeight: list.delegateHeight
                            implicitWidth: ListView.view.width

                            onClicked: {
                                modelData.execute();
                                persist.launcherOpen = false;
                            }

                            RowLayout {
                                id: delegateLayout

                                anchors {
                                    verticalCenter: parent.verticalCenter
                                    left: parent.left
                                    leftMargin: 5
                                }

                                IconImage {
                                    Layout.alignment: Qt.AlignVCenter
                                    asynchronous: true
                                    implicitSize: 30
                                    source: Quickshell.iconPath(entryMouseArea.modelData.icon)
                                }

                                StyledText {
                                    text: entryMouseArea.modelData.name
                                    Layout.alignment: Qt.AlignVCenter
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    function init() {
    }
}
