pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import ".."

Item {
    id: root
    property alias model: buttonRepeater.model
    property int currentIndex: 0

    RowLayout {
        id: buttonGroup
        spacing: 0
        anchors.fill: parent

        Repeater {
            id: buttonRepeater

            delegate: MouseArea {
                id: button
                hoverEnabled: true
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop

                required property var modelData
                required property int index
                property bool checked: index === root.currentIndex

                onClicked: {
                    currentIndex = index;
                    root.updateSelectionBarPosition();
                }

                FontIcon {
                    text: button.modelData
                    fill: {
                        if (button.checked)
                            return 1;

                        return button.containsMouse ? 1 : 0;
                    }
                    color: button.checked ? ShellSettings.colors["primary"] : ShellSettings.colors["inverse_surface"]
                    anchors.fill: parent
                    anchors.bottomMargin: 5
                }
            }
        }
    }

    Rectangle {
        id: selectionBar
        implicitWidth: 100
        implicitHeight: 3
        topLeftRadius: width / 2
        topRightRadius: width / 2
        color: ShellSettings.colors["primary"]
        anchors.bottom: tabBar.top

        Behavior on x {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }
    }

    Rectangle {
        id: tabBar
        implicitHeight: 1.5
        radius: width / 2
        color: ShellSettings.colors["surface_container"]

        anchors {
            top: buttonGroup.bottom
            left: parent.left
            right: parent.right
        }
    }

    function updateSelectionBarPosition() {
        if (buttonRepeater.count > 0) {
            var buttonWidth = buttonGroup.width / buttonRepeater.count;
            var targetX = currentIndex * buttonWidth + (buttonWidth - selectionBar.width) / 2;
            selectionBar.x = targetX;
        }
    }

    Component.onCompleted: updateSelectionBarPosition()
    onWidthChanged: updateSelectionBarPosition()
}
