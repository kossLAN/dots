{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkDefault;
  inherit (lib.modules) mkIf;

  cfg = config.programs.nixi;
in
  mkIf cfg.enable {
    environment = {
      systemPackages = with pkgs; [
        quickshell

        # other dependencies for extra functionality
        cava
        gpu-screen-recorder

        # qt packages needed for some functionality
        qt6.qtwayland
        qt6.qt5compat
        qt6.qtdeclarative

        # kde dependencies for qqc2-desktop
        kdePackages.qqc2-desktop-style
        kdePackages.kirigami.unwrapped
        kdePackages.sonnet
      ];
    };

    # Extra functionality for clipping and screen record
    programs.gpu-screen-recorder.enable = mkDefault true;

    systemd = {
      # System-wide settings, things like monitor config, and greeter wallpaper
      tmpfiles.rules = [
        "d /etc/nixi 0777 root root -"
        "f /etc/nixi/settings.json 0777 root root -"
      ];

      user.services.quickshell = {
        enable = true;
        description = "Nixi Service";
        wantedBy = ["graphical-session.target"];
        path = lib.mkForce []; # allow quickshell to access path

        serviceConfig = {
          Type = "simple";
          ExecStart = "${lib.getExe pkgs.quickshell} --config ${../../shell}";
          Restart = "on-failure";
        };
      };
    };
  }
