pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs
import qs.widgets

Singleton {
    PersistentProperties {
        id: persist
        property bool windowOpen: false
    }

    IpcHandler {
        target: "settings"

        function open(): void {
            persist.windowOpen = true;
        }

        function close(): void {
            persist.windowOpen = false;
        }

        function toggle(): void {
            persist.windowOpen = !persist.windowOpen;
        }
    }

    LazyLoader {
        id: loader
        activeAsync: persist.windowOpen

        FloatingWindow {
            color: ShellSettings.colors["background"]
            implicitWidth: 840
            implicitHeight: 845

            // onWidthChanged: {
            //     console.log("height: " + height);
            //     console.log("width: " + width);
            // }

            maximumSize {
                width: 880
                height: 845
            }

            minimumSize {
                width: 880
                height: 845
            }

            onVisibleChanged: {
                if (!visible) {
                    persist.windowOpen = false;
                }
            }

            RowLayout {
                id: layoutRoot
                spacing: 2
                anchors.fill: parent

                property var pageDefinitions: [({
                            title: "Wallpapers",
                            description: "Pick a wallpaper"
                        }), ({
                            title: "Colors",
                            description: "Adjust the palette"
                        })]

                property int currentPageIndex: 0

                
                Rectangle {
                    color: ShellSettings.colors.background
                    Layout.preferredWidth: 175
                    Layout.fillHeight: true

                    ColumnLayout {
                        spacing: 4

                        anchors {
                            fill: parent 
                            margins: 4
                        }

                        // change to listview
                        StyledListView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            spacing: 4
                            model: layoutRoot.pageDefinitions.length

                            delegate: Rectangle {
                                required property int index
                                readonly property bool selected: layoutRoot.currentPageIndex === index
                                readonly property var pageInfo: layoutRoot.pageDefinitions[index]

                                // Layout.fillWidth: true
                                
                                implicitHeight: 24
                                implicitWidth: ListView.view.width 
                                // make sure children do NOT request to fill extra height:
                                // remove any `Layout.fillHeight: true` from the delegate

                                radius: 6
                                color: selected ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(1, 1, 1, 0.04)

                                Text {
                                    text: pageInfo.title
                                    color: ShellSettings.colors.foreground
                                    font.pixelSize: 12
                                    anchors {
                                        verticalCenter: parent.verticalCenter
                                        left: parent.left
                                        leftMargin: 8
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: layoutRoot.currentPageIndex = index
                                    hoverEnabled: true
                                }
                            }
                        }
                    }
                }


                StackLayout {
                    id: pageStack
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    currentIndex: layoutRoot.currentPageIndex

                    WallpaperPicker {}
                    ColorSettings {}
                }
            }
        }
    }

    function init() {
    }
}
