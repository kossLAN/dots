import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

TextField {
    id: root
    color: "white"
    scale: activeFocus ? 1.05 : 1.0
    padding: 8
    focus: true
    echoMode: TextInput.Password
    inputMethodHints: Qt.ImhSensitiveData
    font.pointSize: 11
    horizontalAlignment: Text.AlignHCenter

    background: Rectangle {
        color: Qt.rgba(1, 1, 1, 0.1)
        border.color: root.activeFocus ? Qt.rgba(1, 1, 1, 0.5) : Qt.rgba(1, 1, 1, 0.2)
        border.width: 1
        radius: 8

        layer.enabled: true
        layer.effect: FastBlur {
            radius: 10
            transparentBorder: true
        }
    }

    transform: Translate {
        id: shakeTransform
        x: 0
    }

    property bool shaking: false

    onShakingChanged: {
        if (shaking)
            shakeAnimation.start();
    }

    Behavior on scale {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    SequentialAnimation {
        id: shakeAnimation

        NumberAnimation {
            target: shakeTransform
            property: "x"
            to: -8
            duration: 50
            easing.type: Easing.OutQuad
        }
        NumberAnimation {
            target: shakeTransform
            property: "x"
            to: 8
            duration: 100
            easing.type: Easing.InOutQuad
        }
        NumberAnimation {
            target: shakeTransform
            property: "x"
            to: -6
            duration: 80
            easing.type: Easing.InOutQuad
        }
        NumberAnimation {
            target: shakeTransform
            property: "x"
            to: 6
            duration: 80
            easing.type: Easing.InOutQuad
        }
        NumberAnimation {
            target: shakeTransform
            property: "x"
            to: -3
            duration: 60
            easing.type: Easing.InOutQuad
        }

        onFinished: {
            root.shaking = false;
            root.text = "";
        }
    }
}
