pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    property alias settings: jsonAdapter.settings
    property alias colors: jsonAdapter.colors

    FileView {
        path: `${Quickshell.env("XDG_DATA_HOME")}/quickshell/settings.json`
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        blockLoading: true

        JsonAdapter {
            id: jsonAdapter

            property JsonObject settings: JsonObject {
                property int barHeight: 25
                property string wallpaperUrl: Qt.resolvedUrl("root:resources/wallpapers/pixelart0.jpg")
                property string colorScheme: "scheme-fruit-salad"
                property string screenshotPath: "/home/koss/Pictures"
            }

            property var colors: {
                "background": "#131313",
                "error": "#ffb4ab",
                "error_container": "#93000a",
                "inverse_on_surface": "#303030",
                "inverse_primary": "#9c4236",
                "inverse_surface": "#e2e2e2",
                "on_background": "#e2e2e2",
                "on_error": "#690005",
                "on_error_container": "#ffdad6",
                "on_primary": "#5f150d",
                "on_primary_container": "#ffdad4",
                "on_primary_fixed": "#410000",
                "on_primary_fixed_variant": "#7d2b21",
                "on_secondary": "#442925",
                "on_secondary_container": "#ffdad4",
                "on_secondary_fixed": "#2c1512",
                "on_secondary_fixed_variant": "#5d3f3b",
                "on_surface": "#e2e2e2",
                "on_surface_variant": "#c6c6c6",
                "on_tertiary": "#3e2e04",
                "on_tertiary_container": "#fbdfa6",
                "on_tertiary_fixed": "#251a00",
                "on_tertiary_fixed_variant": "#564419",
                "outline": "#919191",
                "outline_variant": "#474747",
                "primary": "#ffb4a8",
                "primary_container": "#7d2b21",
                "primary_fixed": "#ffdad4",
                "primary_fixed_dim": "#ffb4a8",
                "scrim": "#000000",
                "secondary": "#e7bdb6",
                "secondary_container": "#5d3f3b",
                "secondary_fixed": "#ffdad4",
                "secondary_fixed_dim": "#e7bdb6",
                "shadow": "#000000",
                "source_color": "#df4332",
                "surface": "#131313",
                "surface_bright": "#393939",
                "surface_container": "#1f1f1f",
                "surface_container_high": "#2a2a2a",
                "surface_container_highest": "#353535",
                "surface_container_low": "#1b1b1b",
                "surface_container_lowest": "#0e0e0e",
                "surface_dim": "#131313",
                "surface_tint": "#ffb4a8",
                "surface_variant": "#474747",
                "tertiary": "#dec38c",
                "tertiary_container": "#564419",
                "tertiary_fixed": "#fbdfa6",
                "tertiary_fixed_dim": "#dec38c"
            }
        }
    }
}
