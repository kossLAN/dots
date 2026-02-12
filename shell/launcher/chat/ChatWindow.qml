pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

import qs
import qs.widgets
import qs.services.chat

ColumnLayout {
    id: root

    spacing: 0

    RowLayout {
        spacing: 16

        Layout.fillWidth: true
        Layout.preferredHeight: 32
        Layout.margins: 4
        Layout.leftMargin: 16

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

            property bool autoScroll: true

            spacing: 0
            clip: true
            cacheBuffer: 2000 // needs to be a pretty big buffer, otherwise scrolling will freak out
            anchors.fill: parent

            ScrollBar.vertical: ScrollBar {}

            onMovingChanged: {
                if (moving) {
                    autoScroll = false;
                } else {
                    if (atYEnd) {
                        autoScroll = true;
                    }
                }
            }

            model: ChatConnector.history

            footer: Rectangle {
                width: messagesList.width
                height: ChatConnector.currentResponse !== "" ? streamingContent.height + 16 : 0
                color: "transparent"

                ChatResponse {
                    id: streamingContent
                    visible: ChatConnector.currentResponse !== ""
                    text: ChatConnector.currentResponse
                    implicitWidth: messagesList.width - 16

                    anchors {
                        top: parent.top
                        right: parent.right
                        margins: 8
                    }
                }
            }

            delegate: Rectangle {
                id: messageDelegate

                required property var modelData
                required property int index

                property bool isUser: modelData.role === "user"

                implicitWidth: ListView.view.width
                implicitHeight: (isUser ? userRequest.height : markdownContent.height) + 16
                color: messageHover.hovered ? ShellSettings.colors.active.light : "transparent"

                HoverHandler {
                    id: messageHover
                }

                // User message
                ChatRequest {
                    id: userRequest
                    visible: messageDelegate.isUser
                    text: messageDelegate.modelData.content
                    images: messageDelegate.modelData.images ?? []
                    implicitWidth: messagesList.width - 16

                    anchors {
                        top: parent.top
                        right: parent.right
                        margins: 8
                    }
                }

                // Assistant message
                ChatResponse {
                    id: markdownContent
                    visible: !messageDelegate.isUser
                    text: messageDelegate.modelData.content
                    implicitWidth: messagesList.width - 16

                    anchors {
                        top: parent.top
                        right: parent.right
                        margins: 8
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

            function scrollToBottom() {
                positionViewAtEnd();
            }

            function scrollToBottomDelayed() {
                positionViewAtEnd();
                Qt.callLater(positionViewAtEnd);
            }

            Component.onCompleted: scrollToBottomDelayed()

            Connections {
                target: ChatConnector

                function onHistoryUpdated() {
                    messagesList.scrollToBottomDelayed();
                }

                function onResponseChunk() {
                    if (messagesList.autoScroll) {
                        messagesList.scrollToBottom();
                    }
                }
            }

            Connections {
                target: root

                function onVisibleChanged() {
                    if (root.visible) {
                        messagesList.scrollToBottomDelayed();
                    }
                }
            }
        }

        StyledButton {
            visible: !messagesList.autoScroll
            color: ShellSettings.colors.active.dark
            hoverColor: color.lighter(1.25)
            width: 32
            height: 32
            onClicked: {
                messagesList.autoScroll = true;
                messagesList.scrollToBottomDelayed();
            }

            anchors {
                right: parent.right
                bottom: parent.bottom
                margins: 16
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
        Layout.leftMargin: 8
        Layout.rightMargin: 8
        Layout.topMargin: 8

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
        Layout.margins: 8

        onAccepted: (message, images) => {
            ChatConnector.sendMessage(message, images);
            clear();
        }

        onStopRequested: ChatConnector.cancelRequest()
    }
}
