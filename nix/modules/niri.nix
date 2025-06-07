{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkDefault mkMerge;
  inherit (lib.modules) mkIf;

  cfg = config.programs.nixi;

  # To be replaced with flake
  niri = pkgs.niri;
in {
  config = mkIf cfg.enable (
    mkMerge [
      {
        environment.systemPackages = [niri];
        systemd.packages = [niri];
        services.displayManager.sessionPackages = [niri];
        programs.dconf.enable = mkDefault true;

        xdg.portal = {
          enable = true;
          xdgOpenUsePortal = true;
          configPackages = [niri];
          config.niri = {
            default = ["kde" "gnome"];

            # Unfortunately for me I'm stuck with this on Niri
            "org.freedesktop.impl.portal.ScreenCast" = mkDefault "gnome";
          };

          extraPortals = with pkgs; [
            kdePackages.xdg-desktop-portal-kde
            xdg-desktop-portal-gnome
          ];
        };
      }

      (import "${inputs.nixpkgs}/nixos/modules/programs/wayland/wayland-session.nix" {
        inherit lib pkgs;
        enableWlrPortal = false;
        enableXWayland = false;
      })
    ]
  );
}
