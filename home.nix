{ pkgs, ... }:
with import <nixpkgs> {};
with builtins;
with lib;
with import <home-manager/modules/lib/dag.nix> { inherit lib; };

{
  programs.home-manager.enable = true;
}
