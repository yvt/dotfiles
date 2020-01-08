{ pkgs, ... }:
{
  # LSDeluxe (https://github.com/Peltoche/lsd)
  programs.lsd = {
    enable = true;
    enableAliases = true;
  };
}
