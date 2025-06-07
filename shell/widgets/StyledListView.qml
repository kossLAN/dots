import QtQuick

ListView {
    id: root

    add: Transition {
        NumberAnimation {
            property: "opacity"
            from: 0
            to: 1
            duration: 100
        }
    }

    displaced: Transition {
        NumberAnimation {
            property: "x,y"
            duration: 200
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            property: "opacity"
            to: 1
            duration: 100
        }
    }

    move: Transition {
        NumberAnimation {
            property: "x,y"
            duration: 200
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            property: "opacity"
            to: 1
            duration: 100
        }
    }

    remove: Transition {
        NumberAnimation {
            property: "x,y"
            duration: 200
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            property: "opacity"
            to: 0
            duration: 100
        }
    }
}
