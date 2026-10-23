{
  lib,
  stdenv,
  curl,
  cacert,
}:

let
  data = builtins.fromJSON (builtins.readFile ./version.json);
  system = stdenv.hostPlatform.system;

  asset =
    {
      x86_64-linux = "proton-drive-linux-x86_64";
    }
    .${system} or (throw "proton-drive: no release bundle for ${system}");

  url = "https://github.com/atomic-235/proton-drive-flake/releases/download/v${data.version}/${asset}";

  # Self-extracting bundle (arx) with the patched binary and its runtime
  # libraries, so it runs without /nix/store. Nix refuses fixed-output paths
  # whose contents mention store paths, hence the waiver.
  bundle = stdenv.mkDerivation {
    name = "proton-drive-${data.version}-${asset}";

    outputHashMode = "flat";
    outputHashAlgo = "sha256";
    outputHash = data.assets.${system};
    unsafeDiscardReferences = true;

    nativeBuildInputs = [ curl ];

    buildCommand = ''
      export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt
      curl -fsSL --cacert "$SSL_CERT_FILE" -o "$out" ${lib.escapeShellArg url}
    '';
  };
in
stdenv.mkDerivation {
  pname = "proton-drive";
  version = data.version;

  src = bundle;
  dontUnpack = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 "$src" "$out/bin/proton-drive"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Command-line interface for Proton Drive, self-contained release bundle";
    homepage = "https://proton.me/support/drive-cli";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "proton-drive";
  };
}
