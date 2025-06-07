pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Pam

Scope {
    id: root

    property LockState state: LockState {
        onTryUnlock: {
            if (this.currentText === "")
                return;

            this.unlockInProgress = true;
            pam.start();
        }
    }

    PamContext {
        id: pam

        // Its best to have a custom pam config for quickshell, as the system one
        // might not be what your interface expects, and break in some way.
        // This particular example only supports passwords.
        configDirectory: "pam"
        config: "password.conf"

        // pam_unix will ask for a response for the password prompt
        onPamMessage: {
            if (this.responseRequired) {
                this.respond(root.state.currentText);
            }
        }

        // pam_unix won't send any important messages so all we need is the completion status.
        onCompleted: result => {
            if (result == PamResult.Success) {
                root.state.unlocked();
                root.state.currentText = "";
            } else {
                root.state.showFailure = true;
            }

            root.state.unlockInProgress = false;
        }
    }
}
