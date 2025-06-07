{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";

    quickshell = {
      url = "github:outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    qtengine = {
      url = "github:kossLAN/qtengine";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # TBD: niri flake
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    qtengine,
    ...
  }: let
    forEachSystem = fn:
      nixpkgs.lib.genAttrs
      nixpkgs.lib.platforms.linux
      (system: fn system (nixpkgs.legacyPackages.${system}));
  in {
    nixosModules.default = import ./nix/modules inputs;
    overlays.default = import ./nix/overlay.nix {inherit inputs;};

    # Not reccomended to use this method of running the shell
    packages = forEachSystem (system: pkgs: rec {
      default = nixi;
      nixi = pkgs.callPackage ./nix/package.nix {};
    });
  };
}
