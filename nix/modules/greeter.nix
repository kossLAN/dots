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
  users.users.greeter = {
    home = "/home/greeter";
    createHome = true;
  };

  services.greetd = {
    enable = true;

    settings.default_session = {
      user = "greeter";

      command = "${getExe' pkgs.niri "niri"} --config ${pkgs.writeText "greetd-quickshell" ''
        spawn-sh-at-startup "${getExe' pkgs.quickshell "qs"} -p ${../../shell}/greeter.qml >& qslog.txt && pkill niri"

        hotkey-overlay {
          skip-at-startup
        }
      ''}";
    };
  };
})
