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
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    qtengine,
    ...
  }: {
    nixosModules.default = import ./nix/modules inputs;
    overlays.default = import ./nix/overlay.nix inputs;
  };
}
