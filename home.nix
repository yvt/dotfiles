{ pkgs, ... }:
with import <nixpkgs> {};
with builtins;
with lib;
with import <home-manager/modules/lib/dag.nix> { inherit lib; };

{
  imports = filter (e: e != null) [
    (if pathExists ./private then ./private/home.nix else null)
    (if pathExists ./local then ./local/home.nix else null)
  ];

  programs.home-manager.enable = true;
}
