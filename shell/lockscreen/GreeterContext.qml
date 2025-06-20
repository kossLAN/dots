import QtQuick
import Quickshell
import Quickshell.Services.Greetd
import "../lockscreen"

Scope {
    id: root
    signal launch

    property LockState state: LockState {
        onTryUnlock: {
            this.unlockInProgress = true;

            // TODO: env var for user 
            Greetd.createSession("koss");
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
