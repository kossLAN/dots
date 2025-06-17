import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import "../../widgets/" as Widgets
import "../.."

WrapperRectangle {
    id: root
    color: ShellSettings.colors["surface_container"]
    radius: width / 2
    margin: 6

    required property PwNode node
    property string text
    property Component button 
    property Component icon 

    PwObjectTracker {
        id: tracker
        objects: [root.node]
    }

    RowLayout {
        Widgets.MaterialSlider {
            value: root.node.audio.volume ?? 0
            text: root.text
            icon: root.icon

            onValueChanged: {
                // only allow changes when the node is ready other wise you will combust
                if (!root.node.ready)
                    return;

                root.node.audio.volume = value;
            }

            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        Loader {
            id: buttonLoader
            sourceComponent: root.button

            Layout.preferredWidth: this.height
            Layout.fillHeight: true
        }
    }
}
