import Quickshell.Io

import qs

JsonObject {
    // Whether or not to enable gpu-sceen-recorder, here for persistence
    property bool enabled: false

    // -w <window_id|monitor|focused|portal|region|v4l2_device_path>
    // Capture target (use "screen" for primary monitor on Wayland)
    property string window: "screen"

    // -c <container_format>
    // Container format (mp4, mkv, flv, etc.)
    property string containerFormat: "mp4"

    // -s WxH
    // Output size (empty = source size)
    property string size: ""

    // -region WxH+X+Y
    // Region to capture (only when -w region)
    property string region: ""

    // -f <fps>
    // Frames per second
    property int fps: 60

    // -a <audio_input>
    // Audio input devices (can be multiple, comma-separated)
    property string audioInput: "default_input"

    // -q <quality>
    // Quality: very_high, high, medium, low, custom
    property string quality: "very_high"

    // -r <replay_buffer_size_sec>
    // Replay buffer size in seconds (0 = disabled, recording mode)
    property int replayBufferSize: 30

    // -replay-storage ram|disk
    property string replayStorage: "ram"

    // -restart-replay-on-save yes|no
    property bool restartReplayOnSave: true

    // -k h264|hevc|av1|vp8|vp9|hevc_hdr|av1_hdr|hevc_10bit|av1_10bit
    // Video codec
    property string codec: "hevc"

    // -ac aac|opus|flac
    // Audio codec
    property string audioCodec: "opus"

    // -ab <bitrate>
    // Audio bitrate in kbps (e.g., 128, 320)
    property int audioBitrate: 128

    // -oc yes|no
    // Overclock memory transfer rate (NVIDIA only)
    property bool overclock: false

    // -fm cfr|vfr|content
    // Framerate mode
    property string framerateMode: "vfr"

    // -bm auto|qp|vbr|cbr
    // Bitrate mode
    property string bitrateMode: "auto"

    // -cr limited|full
    // Color range
    property string colorRange: "limited"

    // -tune performance|quality
    property string tune: "quality"

    // -df yes|no
    // Date/time folder organization
    property bool dateFolder: false

    // -sc <script_path>
    // Script to run on events
    property string scriptPath: ""

    // -p <plugin_path>
    // Plugin path
    property string pluginPath: ""

    // -cursor yes|no
    // Show cursor
    property bool cursor: true

    // -keyint <value>
    // Keyframe interval in seconds
    property int keyint: 2

    // -restore-portal-session yes|no
    property bool restorePortalSession: true

    // -portal-session-token-filepath filepath
    property string portalSessionTokenPath: ""

    // -encoder gpu|cpu
    property string encoder: "gpu"

    // -fallback-cpu-encoding yes|no
    property bool fallbackCpuEncoding: true

    // -o <output_file>
    // Output file path (for recording mode)
    property string outputFile: ""

    // -ro <output_directory>
    // Replay output directory
    property string replayOutputDir: `${ShellSettings.homeDir}/Videos`

    // -ffmpeg-opts <options>
    // Additional ffmpeg options
    property string ffmpegOpts: ""

    // -low-power yes|no
    property bool lowPower: false

    // -v yes|no
    // Verbose output
    property bool verbose: false
}
