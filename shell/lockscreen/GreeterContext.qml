import QtQuick
import Quickshell
import Quickshell.Services.Greetd
import qs.lockscreen

Scope {
    id: root
    signal launch

    property LockState state: LockState {
        onTryUnlock: {
            this.unlockInProgress = true;

            Greetd.createSession(Quickshell.env("GREETER_USER") || "koss");
        }
    }

    Connections {
        target: Greetd

        function onAuthMessage(message: string, error: bool, responseRequired: bool, echoResponse: bool) {
            if (responseRequired) {
                Greetd.respond(root.state.currentText);
            } // else ignore - only supporting passwords
        }

        function onAuthFailure() {
            root.state.currentText = "";
            root.state.failed();
            root.state.unlockInProgress = false;
        }

        function onReadyToLaunch() {
            root.state.unlockInProgress = false;
            root.launch();
        }
    }
}
