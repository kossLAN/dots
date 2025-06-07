import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs
import qs.widgets

StyledMouseArea {
    id: root
    required property QsMenuEntry entry
    property alias expanded: childrenRevealer.expanded
    property bool animating: childrenRevealer.animating //|| (childMenuLoader?.item?.animating ?? false)

    // appears it won't actually create the handler when only used from MenuItemList.
    onExpandedChanged: {}
    onAnimatingChanged: {}

    signal close

    implicitWidth: column.implicitWidth + 4
    implicitHeight: column.implicitHeight + 4

    hoverEnabled: true
    onClicked: {
        if (entry.hasChildren)
            childrenRevealer.expanded = !childrenRevealer.expanded;
        else {
            entry.triggered();
            close();
        }
    }

    ColumnLayout {
        id: column
        anchors.fill: parent
        anchors.margins: 2
        spacing: 0

        RowLayout {
            id: innerRow
            // Layout.preferredHeight: 22

            Item {
                // visible: checkBox.visible || radioButton.visible || icon.visible
                implicitWidth: 22
                implicitHeight: 22

                MenuCheckBox {
                    id: checkBox
                    anchors.centerIn: parent
                    visible: entry.buttonType == QsMenuButtonType.CheckBox
                    checkState: entry.checkState
                }

                MenuRadioButton {
                    id: radioButton
                    anchors.centerIn: parent
                    visible: entry.buttonType == QsMenuButtonType.RadioButton
                    checkState: entry.checkState
                }

                IconImage {
                    id: icon
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    source: entry.icon
                    visible: source != ""
                    implicitSize: parent.height
                }
            }

            Text {
                Layout.fillWidth: true
                text: entry.text
                color: entry.enabled ? ShellSettings.colors.active.windowText : ShellSettings.colors.active.placeholderText
            }

            Item {
                Layout.fillWidth: true
                implicitWidth: 22
                implicitHeight: 22

                MenuChildrenRevealer {
                    id: childrenRevealer
                    anchors.centerIn: parent
                    visible: entry.hasChildren
                    onOpenChanged: entry.showChildren = open
                }
            }
        }

        Loader {
            id: childMenuLoader
            active: root.expanded || root.animating
            clip: true

            Layout.fillWidth: true
            Layout.preferredWidth: active ? innerRow.implicitWidth + (widthDifference * childrenRevealer.progress) : 0
            Layout.preferredHeight: active ? item.implicitHeight * childrenRevealer.progress : 0

            readonly property real widthDifference: {
                Math.max(0, (item?.implicitWidth ?? 0) - innerRow.implicitWidth);
            }

            sourceComponent: MenuView {
                id: childrenList
                menu: entry
                onClose: root.close()

                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }
            }
        }
    }
}
