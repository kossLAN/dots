{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkDefault;
  inherit (lib.modules) mkIf;

  cfg = config.programs.nixi;

  font = "Rubix";
  fontFixed = "DejaVuSansM Nerd Font";
in {
  config = mkIf cfg.appThemes {
    environment = {
      # Fix for some KDE applications not respecting icon themes
      etc."xdg/kdeglobals".text = ''
        [Icons]
        Theme=${config.programs.qtengine.config.theme.iconTheme}
      '';

      systemPackages = with pkgs; [
        # icons/cursor
        papirus-icon-theme
        apple-cursor

        # qt5/6 Theme
        darkly
        darkly-qt5
      ];

      variables = {
        XCURSOR_THEME = "macOS";
        XCURSOR_SIZE = 24;
      };
    };

    # System-wide font configuration
    fonts = {
      fontDir.enable = true;
      enableDefaultPackages = true;

      packages = with pkgs; [
        rubik
        nerd-fonts.dejavu-sans-mono
      ];

      fontconfig = {
        enable = true;

        defaultFonts = {
          serif = [font];
          sansSerif = [font];
          monospace = [fontFixed];
        };
      };
    };

    programs = {
      dconf = {
        enable = true;
        profiles.user.databases = [
          {
            lockAll = true; # prevents overriding
            settings = {
              "org/gnome/desktop/interface" = {
                # gtk-theme = "Breeze-Dark";
                icon-theme = "Papirus-Dark";
                color-scheme = "prefer-dark";
              };
            };
          }
        ];
      };

      qtengine = {
        enable = mkDefault true;

        config = {
          theme = {
            colorScheme = mkDefault ./Darkly.colors;
            iconTheme = mkDefault "Papirus-Dark";
            style = mkDefault "Darkly";
            quickStyle = mkDefault "org.kde.desktop";

            font = {
              family = mkDefault font;
              size = mkDefault 10;
            };

            fontFixed = {
              family = mkDefault fontFixed;
              size = mkDefault 10;
            };
          };

          misc = {
            singleClickActivate = mkDefault false;
            menusHaveIcons = mkDefault true;
            shortcutsForContextMenus = mkDefault true;
          };
        };
      };
    };
  };
}
