{stdenv}:
stdenv.mkDerivation {
  pname = "nixi";
  version = "0.1.0";
  src = ../shell;

  installPhase = ''
    mkdir -p $out/etc/quickshell
    cp -r * $out/etc/quickshell
  '';
}
