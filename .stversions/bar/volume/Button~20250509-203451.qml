import QtQuick
import Quickshell
import "../../widgets/" as Widgets
import "../.."


Widgets.IconButton {
    required property var bar; 

    id: iconButton
    implicitSize: 20
    source: "root:/resources/volume/volume-full.svg"  
    padding: 2

    onClicked:{  
        if (volumeControl.visible) { 
            volumeControl.hide() 
        }
        else {
            volumeControl.show()
        }
    }

    ControlPanel {
        id: volumeControl 

        anchor { 
            window: bar

            onAnchoring: {
               anchor.rect = mapToItem(bar.contentItem, 0, bar.height, width , 0);   
            }
        } 
    }
}
