inputs: {
  self,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) bool;
in {
  imports = [
    ./shell.nix
    ./greeter.nix
    ./niri.nix
    ./theme.nix

    inputs.qtengine.nixosModules.default
  ];

  config = {
    nixpkgs.overlays = [
      inputs.self.overlays.default
    ];
  };

  options.programs.nixi = {
    enable = mkEnableOption "nixi dots";

    appThemes = mkOption {
      type = bool;
      default = true;
      description = "Enable qt/gtk theming";
    };

    greeter.enable = mkOption {
      type = bool;
      default = true;
      description = "Enable nixi greeter";
    };
  };
}
