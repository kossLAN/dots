pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io


// This thing is a pile of COAL, PLEASE FOX FINISH IMAGE FIX
Item {
    id: root

    property url source: ""
    property url cachedSource: ""
    property bool ready: false
    property string cacheDir: Quickshell.cacheDir + "/images"
    property string cachedPath: ""
    property string sanitizedUrl: ""

    onSourceChanged: {
        ready = false;
        cachedSource = "";
        sanitizedUrl = "";
        
        if (!source || source === "") {
            return;
        }

        const sourceStr = source.toString().trim().replace(/\s+/g, '');
        sanitizedUrl = sourceStr;
        
        if (sourceStr.startsWith("file://") || sourceStr.startsWith("/")) {
            cachedSource = source;
            ready = true;
            return;
        }

        if (sourceStr.startsWith("http://") || sourceStr.startsWith("https://")) {
            const hash = Qt.md5(sourceStr);
            cachedPath = cacheDir + "/" + hash + ".jpg";
            cacheChecker.running = true;
        }
    }

    Process {
        id: mkdirProcess
        command: ["mkdir", "-p", root.cacheDir]
    }

    Process {
        id: cacheChecker
        command: ["test", "-f", root.cachedPath]

        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                root.cachedSource = "file://" + root.cachedPath;
                root.ready = true;
            } else {
                mkdirProcess.running = true;
                downloader.running = true;
            }
        }
    }

    Process {
        id: downloader
        command: ["curl", "-fsSL", "-o", root.cachedPath, root.sanitizedUrl]

        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                root.cachedSource = "file://" + root.cachedPath;
                root.ready = true;
            } else {
                console.warn("CachedImage: Failed to download", root.sanitizedUrl);
            }
        }
    }
}
