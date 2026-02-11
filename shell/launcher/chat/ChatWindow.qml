pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

import qs
import qs.widgets
import qs.services.chat

ColumnLayout {
    id: root

    spacing: 8

    RowLayout {
        spacing: 16

        Layout.fillWidth: true
        Layout.preferredHeight: 32
        Layout.leftMargin: 8

        Rectangle {
            width: 8
            height: 8
            radius: 4
            color: {
                if (ChatConnector.busy)
                    return ShellSettings.colors.active.accent;

                return (ChatConnector.currentProvider?.available ? "#4ade80" : "#ef4444");
            }

            SequentialAnimation on opacity {
                running: ChatConnector.busy
                loops: Animation.Infinite

                NumberAnimation {
                    to: 0.3
                    duration: 500
                }

                NumberAnimation {
                    to: 1.0
                    duration: 500
                }
            }
        }

        ModelDropdown {
            id: modelDropdown
            color: ShellSettings.colors.active.mid

            Layout.preferredWidth: 200
            Layout.preferredHeight: 28

            onSelected: (providerId, model) => ChatConnector.setProviderAndModel(providerId, model)
        }
    }

    Separator {
        Layout.fillWidth: true
        Layout.preferredHeight: 1
    }

    // Messages area
    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true

        ListView {
            id: messagesList
            anchors.fill: parent
            spacing: 16
            clip: true

            property bool atBottom: atYEnd

            onMovingChanged: {
                if (!moving)
                    atBottom = atYEnd;
            }

            model: {
                let _ = ChatConnector.historyVersion;
                return ChatConnector.history;
            }

            function scrollToBottom() {
                positionViewAtEnd();
                atBottom = true;
            }

            Connections {
                target: ChatConnector

                function onHistoryUpdated() {
                    messagesList.scrollToBottom();
                }

                function onResponseChunk() {
                    if (messagesList.atBottom) {
                        messagesList.scrollToBottom();
                    }
                }
            }

            delegate: Item {
                id: messageDelegate

                required property var modelData
                required property int index

                property bool isUser: modelData.role === "user"
                property real maxBubbleWidth: messagesList.width * 0.7

                implicitWidth: messagesList.width
                implicitHeight: messageBubble.height

                StyledRectangle {
                    id: messageBubble

                    property bool hasImages: messageDelegate.isUser && (messageDelegate.modelData.images ?? []).length > 0
                    property real contentWidth: messageDelegate.isUser ? userContent.width : markdownContent.width
                    property real contentHeight: messageDelegate.isUser ? userContent.height : markdownContent.height

                    clip: true
                    implicitWidth: contentWidth + 24
                    implicitHeight: contentHeight + 16
                    color: messageDelegate.isUser ? ShellSettings.colors.active.accent : ShellSettings.colors.active.mid
                    radius: 12

                    anchors {
                        right: messageDelegate.isUser ? parent.right : undefined
                        left: messageDelegate.isUser ? undefined : parent.left
                    }

                    ColumnLayout {
                        id: userContent
                        visible: messageDelegate.isUser
                        spacing: 8

                        implicitWidth: Math.max(messageText.width, imageRow.width)
                        anchors.centerIn: parent

                        // Image row
                        Flow {
                            id: imageRow
                            visible: messageBubble.hasImages
                            spacing: 6
                            Layout.preferredWidth: Math.min(implicitWidth, messageDelegate.maxBubbleWidth - 24)

                            Repeater {
                                model: messageDelegate.modelData.images ?? []

                                delegate: Item {
                                    id: imagePreviewDelegate

                                    required property string modelData

                                    width: 80
                                    height: 80

                                    ClippingRectangle {
                                        color: "transparent"
                                        radius: 6
                                        anchors.fill: parent

                                        Image {
                                            source: "data:image/png;base64," + imagePreviewDelegate.modelData
                                            fillMode: Image.PreserveAspectCrop
                                            smooth: true
                                            anchors.fill: parent
                                        }
                                    }
                                }
                            }
                        }

                        TextEdit {
                            id: messageText
                            color: ShellSettings.colors.active.text
                            text: messageDelegate.modelData.content
                            wrapMode: Text.Wrap
                            font.pixelSize: 13
                            textFormat: TextEdit.MarkdownText
                            readOnly: true
                            selectByMouse: true
                            selectedTextColor: ShellSettings.colors.active.highlightedText
                            selectionColor: ShellSettings.colors.active.highlight

                            Layout.preferredWidth: Math.min(implicitWidth, messageDelegate.maxBubbleWidth - 24)
                        }
                    }

                    MarkdownText {
                        id: markdownContent
                        visible: !messageDelegate.isUser
                        anchors.centerIn: parent
                        text: messageDelegate.modelData.content
                        maxWidth: messageDelegate.maxBubbleWidth - 24
                    }
                }
            }

            // Streaming response indicator
            footer: Item {
                id: streamingFooter
                visible: ChatConnector.currentResponse !== ""
                width: messagesList.width
                height: {
                    if (ChatConnector.currentResponse === "")
                        return 0;

                    if (ChatConnector.history.length > 0)
                        return streamingBubble.height + messagesList.spacing;

                    return streamingBubble.height;
                }

                property real maxBubbleWidth: messagesList.width * 0.7

                StyledRectangle {
                    id: streamingBubble
                    width: Math.min(streamingContent.width + 24, streamingFooter.maxBubbleWidth)
                    height: streamingContent.height + 16
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    color: ShellSettings.colors.active.mid
                    radius: 12
                    clip: true

                    MarkdownText {
                        id: streamingContent
                        anchors.centerIn: parent
                        text: ChatConnector.currentResponse
                        maxWidth: streamingFooter.maxBubbleWidth - 24
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                visible: ChatConnector.history.length === 0 && ChatConnector.currentResponse === ""
                color: ShellSettings.colors.active.text
                opacity: 0.5
                font.pixelSize: 14

                text: {
                    if (ChatConnector.currentProvider?.available)
                        return "Start a conversation...";

                    return "Connecting to service...";
                }
            }
        }

        StyledButton {
            visible: !messagesList.atBottom
            color: ShellSettings.colors.active.mid
            width: 32
            height: 32
            onClicked: messagesList.scrollToBottom()

            anchors {
                right: parent.right
                bottom: parent.bottom
                margins: 8
            }

            IconImage {
                source: Quickshell.iconPath("draw-arrow-down")

                anchors {
                    fill: parent
                    margins: 4
                }
            }
        }
    }

    StyledRectangle {
        visible: ChatConnector.errorMessage !== ""
        color: "#7f1d1d"
        radius: 6

        Layout.fillWidth: true
        Layout.preferredHeight: errorText.implicitHeight + 12

        Text {
            id: errorText
            anchors.fill: parent
            anchors.margins: 6
            color: "#fecaca"
            text: ChatConnector.errorMessage
            wrapMode: Text.Wrap
            font.pixelSize: 12
        }
    }

    ChatTextBox {
        id: messageInput
        placeholderText: "Type a message..."
        busy: ChatConnector.busy
        supportsImages: ChatConnector.currentProvider?.supportsImages ?? false

        Layout.fillWidth: true

        onAccepted: (message, images) => {
            ChatConnector.sendMessage(message, images);
            clear();
        }

        onStopRequested: ChatConnector.cancelRequest()
    }
}
