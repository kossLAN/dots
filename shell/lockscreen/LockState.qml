import Quickshell

Scope {
    property string currentText: ""
    property bool unlockInProgress: false
    property bool showFailure: false
    signal unlocked
    signal failed
    signal tryUnlock

    onCurrentTextChanged: showFailure = false
}
