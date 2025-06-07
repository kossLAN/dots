//@ pragma UseQApplication

import Quickshell
import Quickshell.Io
import QtQuick
import "bar" as Bar
import "notifications" as Notifications
import "launcher" as Launcher

ShellRoot {
    Component.onCompleted: [Launcher.Controller.init()]

    Variants {
        model: {
            // Check PriorityScreens for priortized screens, I only want the bar showing on
            // screen at a time, because it doesnt make alot of sense to have on multiple
            // monitors at a time.
            const screens = Quickshell.screens;
            console.log("Available Screens: " + screens.map(screen => screen.model));

            const priorityScreen = PriorityScreens.screens.reduce((found, model) => {
                if (found)
                    return found;
                return screens.find(screen => screen.model === model);
            }, null);

            return priorityScreen ? [priorityScreen] : [];
        }

        Scope {
            id: scope
            property var modelData

            Bar.Bar {
                screen: scope.modelData
            }

            Notifications.Notifications {
                screen: scope.modelData
            }

            Process {
                id: xPrimaryMoniorSetter
                running: true
                command: ["xrandr", "--output", scope.modelData.name, "--primary"]
            }
        }
    }

    ReloadPopup {}
}
