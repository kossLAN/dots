inputs: {
  self,
  lib,
  config,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) bool;
in {
  imports = [
    ./shell.nix
    ./greeter.nix
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
      default = config.programs.nixi.enable;
      description = "Enable qt/gtk theming";
    };

    greeter.enable = mkOption {
      type = bool;
      default = config.programs.nixi.enable;
      description = "Enable nixi greeter";
    };
  };
}
