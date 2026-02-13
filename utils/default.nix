{
  stdenv,
  cmake,
  qt6,
}:
stdenv.mkDerivation {
  name = "utils-plugin";
  src = ./.;

  buildInputs = [
    qt6.qtbase
    qt6.qtdeclarative
  ];

  nativeBuildInputs = [
    cmake
  ];

  dontWrapQtApps = true;
}
