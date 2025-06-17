{
  description = "kossLAN's quickshell dots";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    forEachSystem = fn:
      nixpkgs.lib.genAttrs
      ["x86_64-linux" "aarch64-linux"]
      (system: fn system nixpkgs.legacyPackages.${system});
  in {
    packages = forEachSystem (system: pkgs: rec {
      default = minmat;
      minmat = pkgs.stdenv.mkDerivation {
        pname = "minmat";
        version = "0.1.0";
        src = ./shell;

        installPhase = ''
          mkdir -p $out/etc/quickshell
          cp -r * $out/etc/quickshell
        '';
      };
    });
  };
}
