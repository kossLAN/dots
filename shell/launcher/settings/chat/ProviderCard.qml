import QtQuick
import QtQuick.Layouts

import qs
import qs.widgets

Item {
    id: root

    required property var provider

    property string providerName: provider?.name ?? ""
    property string providerIcon: provider?.icon ?? ""
    property bool available: provider?.available ?? false
    property int modelCount: provider?.models?.length ?? 0
    property string errorMessage: provider?.errorMessage ?? ""

    RowLayout {
        anchors.fill: parent
        spacing: 12

        Image {
            source: root.providerIcon
            sourceSize.width: 24
            sourceSize.height: 24
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            visible: source !== ""
        }

        ColumnLayout {
            spacing: 2

            Layout.fillWidth: true
            Layout.fillHeight: true

            RowLayout {
                spacing: 6

                StyledText {
                    text: root.providerName
                    font.pointSize: 9
                }

                Rectangle {
                    implicitWidth: 8
                    implicitHeight: 8
                    radius: 4
                    color: root.available ? ShellSettings.colors.extra.open : ShellSettings.colors.extra.close
                }
            }

            StyledText {
                text: {
                    if (root.available)
                        return `${root.modelCount} models available`;
                    return root.errorMessage || "Not available";
                }
                font.pointSize: 9
                opacity: 0.7
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
