# proton-drive-flake

The official [Proton Drive CLI](https://proton.me/support/drive-cli), patched for
NixOS and published as a **self-contained arx bundle**.

Proton ships a dynamically linked Bun binary that `dlopen`s libsecret, so it
cannot run on NixOS unmodified. `unbundled.nix` installs it with
`autoPatchelfHook` and wraps it with `LD_LIBRARY_PATH`; CI then bundles the
result so consumers fetch one file instead of redoing the patching.

## Packages

| Attribute | Contents |
|---|---|
| `packages.<system>.default` | the published bundle |
| `packages.<system>.proton-drive` | alias of `default` |
| `packages.<system>.unbundled` | upstream binary + patchelf + wrapper |

`overlays.default` provides `pkgs.proton-drive`.

## Usage

```nix
{
  inputs.proton-drive-flake.url = "github:atomic-235/proton-drive-flake";
  inputs.proton-drive-flake.inputs.nixpkgs.follows = "nixpkgs";
}
```

```nix
nixpkgs.overlays = [ inputs.proton-drive-flake.overlays.default ];
# pkgs.proton-drive
```

## Updates

Upstream publishes a manifest at
`https://proton.me/download/drive/cli/version.json` with the stable channel,
its version and the sha512 of each artifact. CI runs weekly (Monday 06:00 UTC),
reads the `Stable` release, takes the `linux-x64` file (not the musl build,
which needs a loader NixOS does not have), rebuilds, uploads
`proton-drive-linux-x86_64`, verifies the bundle starts, then commits and tags
`v<version>`.

Only `x86_64-linux` is published.
