{ pkgs, config, lib, ... }:

with lib;

{
  programs.ssh.matchBlocks = {
    "example.com" = {
      port = 2200;
    };
  };

  programs.unison = {
    enable = true;

    profiles.example =
      ''
      root = /localdir
      root = ssh://www.example.com/remotedir
      '';
  };
}
