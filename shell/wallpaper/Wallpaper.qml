import Quickshell
import QtQuick
import qs

Scope {
    id: root

    LazyLoader {
        loading: true

        Scope {
            WallpaperPanel {}
            WallpaperOverview {}

            Connections {
                target: ShellSettings.settings

                function onWallpaperUrlChanged() {
                    console.info("Switching wallpaper: " + ShellSettings.settings.wallpaperUrl);
                }
            }
        }
    }
}
