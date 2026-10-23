{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  glib,
  libgcrypt,
  libsecret,
}:

let
  data = builtins.fromJSON (builtins.readFile ./version.json);
in
stdenv.mkDerivation {
  pname = "proton-drive";
  version = data.version;

  src = fetchurl {
    url = "https://proton.me/download/drive/cli/${data.version}/linux-x64/proton-drive";
    hash = data.upstreamHash;
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];
  buildInputs = [
    stdenv.cc.cc.lib
    libsecret
  ];

  dontUnpack = true;

  # strip destroys Bun's embedded JS payload -> binary falls back to Bun CLI
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 "$src" "$out/bin/proton-drive"
    wrapProgram "$out/bin/proton-drive" \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          glib
          libgcrypt
          libsecret
        ]
      }
    runHook postInstall
  '';

  meta = with lib; {
    description = "Command-line interface for Proton Drive";
    homepage = "https://proton.me/support/drive-cli";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "proton-drive";
  };
}
