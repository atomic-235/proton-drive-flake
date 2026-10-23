{
  description = "Proton Drive CLI as a self-contained release bundle";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs, ... }:
    let
      systems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        rec {
          # What consumers get: the published bundle, no patching.
          default = pkgs.callPackage ./package.nix { };

          # What CI builds (upstream binary + patchelf) before bundling it.
          unbundled = pkgs.callPackage ./unbundled.nix { };

          proton-drive = default;
        }
      );

      overlays.default = final: _prev: {
        proton-drive = final.callPackage ./package.nix { };
      };
    };
}
