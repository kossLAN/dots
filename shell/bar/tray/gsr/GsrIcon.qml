import QtQuick

import qs

Item {
    id: root

    property bool running: true 

    Rectangle {
        id: center
        radius: height / 2
        color: root.running ? ShellSettings.colors.extra.close : "#DFDFDF"
        opacity: root.running ? 1 : 0.25
        antialiasing: true
        anchors.fill: parent

        SequentialAnimation on opacity {
            running: root.running
            loops: Animation.Infinite

            NumberAnimation {
                from: 1.0
                to: 0.3
                duration: 800
                easing.type: Easing.InOutQuad
            }

            NumberAnimation {
                from: 0.3
                to: 1.0
                duration: 800
                easing.type: Easing.InOutQuad
            }
        }
    }


    // Rectangle {
    //     color: "transparent"
    //     radius: height / 2
    //
    //     border {
    //         color: "#DFDFDF"
    //         width: center.width / 5 
    //     }
    //
    //     anchors {
    //         fill: parent
    //     }
    // }
}
