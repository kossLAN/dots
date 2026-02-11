{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) getExe';
  inherit (lib.modules) mkIf;

  cfg = config.programs.nixi.greeter;
in (mkIf cfg.enable {
  services.greetd = {
    enable = true;

    settings.default_session = {
      user = "greeter";

      command = "${getExe' pkgs.niri "niri"} --config ${pkgs.writeText "greetd-quickshell" ''
        spawn-sh-at-startup "${getExe' pkgs.quickshell "qs"} -p ${../../shell}/greeter.qml && pkill niri"

        hotkey-overlay {
          skip-at-startup
        }
      ''}";
    };
  };
})
