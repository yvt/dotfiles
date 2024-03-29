# Overrides certain packages to use the Intel build.
#
# Nix should be [updated][1] to 2.3.17 or later for this to work on macOS 11.5.0
# and later[2].
#
# [1]: https://nixos.org/manual/nix/stable/#ch-upgrading-nix
# [2]: https://github.com/NixOS/nix/pull/5388
{ pkgs, lib, config, ... }:

with lib;

let
  x86_64-darwin = lib.systems.elaborate {
    config = "x86_64-apple-darwin";
    xcodePlatform = "MacOSX";
    platform = {};
  };

  pkgsIntel = import <nixpkgs> { localSystem = x86_64-darwin; };
in
{
  nixpkgs.overlays = [ (self: super: {
    # Binary distribution availability
    gcc-arm-embedded = pkgsIntel.gcc-arm-embedded;
  } ) ];
}
