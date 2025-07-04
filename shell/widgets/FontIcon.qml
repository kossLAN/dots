import QtQuick
import ".."

Text {
    id: textIcon

    property real fill: 0

    renderType: Text.NativeRendering
    textFormat: Text.PlainText
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter

    font {
        family: "Material Symbols Outlined"
        pointSize: Math.max(parent.height * 0.50, 11)

        variableAxes: {
            "FILL": fill
        }
    }

    Behavior on fill {
        NumberAnimation {
            duration: 200
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: 200
        }
    }
}
