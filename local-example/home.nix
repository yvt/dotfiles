{ pkgs, config, lib, ... }:

with lib;

{
  home.stateVersion = "22.05";
  home.username = "me";
  home.homeDirectory = "/home/me";
}
