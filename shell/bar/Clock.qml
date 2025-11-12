import QtQuick
import Quickshell
import qs.widgets

StyledText {
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

    text: `${hours}:${minutes} ${ap}`
    font.pointSize: 11
}
