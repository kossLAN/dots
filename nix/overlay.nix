inputs: (final: _prev: let
  system = final.stdenv.hostPlatform.system;
in {
  quickshell = inputs.quickshell.packages.${system}.default.override {
    withJemalloc = true;
    withQtSvg = true;
    withWayland = true;
    withX11 = false;
    withPipewire = true;
    withPam = true;
    withHyprland = false;
  };

  nixiutils = final.callPackage ../utils {};
})
