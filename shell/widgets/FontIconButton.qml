import QtQuick
import ".."

MaterialButton {
    id: root

    property real implicitSize
    property string iconName: ""
    property string activeIconColor: ShellSettings.colors.active.highlightedText
    property string inactiveIconColor: ShellSettings.colors.active.windowText

    implicitWidth: this.implicitSize
    implicitHeight: this.implicitSize

    Text {
        id: textIcon
        text: root.iconName
        renderType: Text.NativeRendering
        textFormat: Text.PlainText
        color: root.containsMouse || root.checked ? root.activeIconColor : root.inactiveIconColor 
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        anchors.fill: parent

        font {
            family: "Material Symbols Outlined"
            pointSize: Math.max(parent.height * 0.60, 11)

            variableAxes: {
                "FILL": fill
            }
        }

        property real fill: !root.containsMouse && !root.checked ? 0 : 1

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
}
