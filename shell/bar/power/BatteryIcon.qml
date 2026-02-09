import Quickshell
import Quickshell.Services.UPower
import Quickshell.Widgets

IconImage {
    property var device: UPower.displayDevice

    source: {
        if (!device || !device.ready)
            return Quickshell.iconPath("gpm-battery-missing");

        const percentage = device.percentage;
        const isCharging = device.state === 1;

        let iconName = "gpm-battery-";

        if (percentage >= 0.95) {
            iconName += "100";
        } else if (percentage >= 0.75) {
            iconName += "080";
        } else if (percentage >= 0.55) {
            iconName += "060";
        } else if (percentage >= 0.35) {
            iconName += "040";
        } else if (percentage >= 0.15) {
            iconName += "020";
        } else {
            iconName += "000";
        }

        if (isCharging) {
            iconName += "-charging";
        }

        return Quickshell.iconPath(iconName);
    }
}
