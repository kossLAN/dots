pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Polkit
import qs
import qs.widgets

StyledRectangle {
    id: root

    required property AuthFlow flow

    width: loader.width + 16
    height: loader.height + 16

    Loader {
        id: loader
        active: root.flow
        anchors.centerIn: parent

        sourceComponent: ColumnLayout {
            id: rootLayout
            spacing: 12

            RowLayout {
                spacing: 8

                Layout.fillWidth: true

                IconImage {
                    source: Quickshell.iconPath(root.flow.iconName, "dialog-password")

                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                }

                StyledText {
                    text: root.flow.message
                    wrapMode: Text.Wrap
                    verticalAlignment: Text.AlignVCenter

                    Layout.fillWidth: true
                    Layout.maximumWidth: 300
                }
            }

            StyledText {
                visible: root.flow.supplementaryMessage !== ""
                text: root.flow.supplementaryMessage
                color: root.flow.supplementaryIsError ? "#ff6b6b" : ShellSettings.colors.active.text
                wrapMode: Text.Wrap
                font.italic: true

                Layout.fillWidth: true
                Layout.maximumWidth: 300
            }

            RowLayout {
                visible: root.flow.isResponseRequired
                spacing: 4

                Layout.fillWidth: true
                Layout.preferredHeight: 32

                StyledTextInput {
                    id: textInput
                    isSensitive: !root.flow.responseVisible
                    placeholderText: root.flow.inputPrompt
                    focus: true

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    onAccepted: root.flow.submit(text)

                    Keys.onEscapePressed: {
                        console.info("Polkit Agent Request Cancelled");
                        root.flow.cancelAuthenticationRequest();
                    }

                    Connections {
                        target: root.flow

                        function onFailedChanged() {
                            if (root.flow.failed) {
                                textInput.shaking = true;
                            }
                        }

                        function onIsResponseRequiredChanged() {
                            if (root.flow.isResponseRequired) {
                                textInput.clear();
                                textInput.forceActiveFocus();
                            }
                        }
                    }
                }

                StyledButton {
                    Layout.preferredWidth: height
                    Layout.fillHeight: true

                    onClicked: root.flow.cancelAuthenticationRequest()

                    IconImage {
                        source: Quickshell.iconPath("dialog-close")

                        anchors {
                            fill: parent
                            margins: 4
                        }
                    }
                }

                StyledButton {
                    Layout.preferredWidth: height
                    Layout.fillHeight: true

                    onClicked: root.flow.submit(textInput.text)

                    IconImage {
                        source: Quickshell.iconPath("check-filled")

                        anchors {
                            fill: parent
                            margins: 4
                        }
                    }
                }
            }
        }
    }
}
