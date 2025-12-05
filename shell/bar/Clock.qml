import QtQuick
import Quickshell
import qs.widgets
import qs.notifications
import qs

StyledMouseArea {
    id: root
    implicitWidth: text.contentWidth
    implicitHeight: parent.height


    required property var bar

    onClicked: {
        NotificationCenter.api.toggle();
        bar.popup.activeItem = null;
    }

    StyledText {
        id: text
        color: ShellSettings.colors.foreground
        text: `${hours}:${minutes} ${ap}`
        font.pointSize: 11
        font.family: "DejaVu Sans"
        anchors.centerIn: parent

        property string ap: sysClock.hours >= 12 ? "PM" : "AM"
        property string minutes: sysClock.minutes.toString().padStart(2, '0')
        property string hours: {
            var value = sysClock.hours % 12;
            if (value === 0)
                return 12;
            return value;
        }

        SystemClock {
            id: sysClock
            enabled: true
        }
    }
}
