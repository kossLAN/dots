{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkDefault optionals;
  inherit (lib.modules) mkIf;

  cfg = config.programs.nixi;
in
  mkIf cfg.enable {
    environment = {
      etc."xdg/quickshell".source = ../../shell;

      systemPackages = with pkgs;
        [
          quickshell

          # other dependencies for extra functionality
          cava # music visualizer (will probably get rid of in the future)
          kdePackages.syntax-highlighting # ai chat syntax-highlighting

          # qt packages needed for some functionality
          qt6.qtwayland
          qt6.qt5compat
          qt6.qtdeclarative

          # kde dependencies for qqc2-desktop
          kdePackages.qqc2-desktop-style
          kdePackages.kirigami.unwrapped
          kdePackages.sonnet

          # custom utils
          nixiutils
        ]
        ++ optionals config.programs.gpu-screen-recorder.enable [
          gpu-screen-recorder # recording
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

      user.services.nixi = {
        enable = true;
        description = "Nixi Service";
        wantedBy = ["graphical-session.target"];
        path = lib.mkForce []; # allow quickshell to access path

        serviceConfig = {
          Type = "simple";
          ExecStart = "${lib.getExe pkgs.quickshell} --config /etc/xdg/quickshell";
          Restart = "on-failure";
        };
      };
    };
  }
