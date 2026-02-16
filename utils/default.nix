{
  callPackage,
  stdenv,
  cmake,
  pkg-config,
  qt6,
  microtex ? callPackage ./microtex.nix {},
  tinyxml-2,
}:
stdenv.mkDerivation {
  name = "utils-plugin";
  src = ./.;

  buildInputs = [
    qt6.qtbase
    qt6.qtdeclarative
    microtex
    tinyxml-2
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  cmakeFlags = [
    "-DMICROTEX_RES_DIR=${microtex}/share/microtex/res"
  ];

  dontWrapQtApps = true;
}
