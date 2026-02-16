pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs

SettingsBacker {
    icon: "settings"

    enabled: ShellSettings.settings.debugEnabled

    summary: "Debug Viewer"
    label: "Debug"

    content: Item {
        ColumnLayout {
            Text {
                id: text
                text: `Font: ${text.font}, Color: ${text.color}`
                color: "white"
            }
        }
    }
}
