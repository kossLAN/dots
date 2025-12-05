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

        property int width: 800
        property int height: 650

        FloatingWindow {
            color: ShellSettings.colors.background
            implicitWidth: loader.width
            implicitHeight: loader.height

            maximumSize {
                width: loader.width
                height: loader.height
            }

            minimumSize {
                width: loader.width
                height: loader.height
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

                property int currentPageIndex: 0
                property var currentPage: pageDefinitions[currentPageIndex]
                property var pageDefinitions: [
                    {
                        title: "Wallpapers",
                        description: "Change your wallpaper"
                    },
                    {
                        title: "Colors",
                        description: "Edit your color scheme"
                    }
                ]

                ColumnLayout {
                    spacing: 4
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    StyledListView {
                        clip: true
                        spacing: 4
                        model: layoutRoot.pageDefinitions.length

                        Layout.preferredWidth: 165
                        Layout.fillHeight: true
                        Layout.margins: 4

                        delegate: StyledMouseArea {
                            id: entry

                            required property int index
                            readonly property var title: layoutRoot.pageDefinitions[index].title

                            implicitHeight: 24
                            implicitWidth: ListView.view.width

                            radius: 6
                            onClicked: layoutRoot.currentPageIndex = index
                            checked: layoutRoot.currentPageIndex === index

                            Text {
                                text: entry.title
                                color: ShellSettings.colors.foreground
                                font.pixelSize: 12

                                anchors {
                                    verticalCenter: parent.verticalCenter
                                    left: parent.left
                                    leftMargin: 8
                                }
                            }
                        }
                    }
                }

                ColumnLayout {
                    spacing: 0
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 25

                        StyledText {
                            text: layoutRoot.currentPage.description
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            anchors.fill: parent
                        }
                    }

                    Rectangle {
                        color: ShellSettings.colors.background
                        clip: true
                        topLeftRadius: 12

                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        // TODO: Add a border to this rectangle using a path arc or something

                        StackLayout {
                            id: pageStack
                            currentIndex: layoutRoot.currentPageIndex
                            anchors.fill: parent

                            WallpaperPicker {}
                            ColorSettings {}
                        }
                    }
                }
            }
        }
    }

    function init() {
    }
}
