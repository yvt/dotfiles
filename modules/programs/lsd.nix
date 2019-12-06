{ pkgs, ... }:
{
  # LSDeluxe (https://github.com/Peltoche/lsd)
  programs.lsd = {
    enable = true;
    enableAliases = true;
  };

  # <home-manager/modules/programs/lsd.nix> does not come with fish aliases
  programs.fish.shellAliases = {
    ls = "${pkgs.lsd}/bin/lsd";
    ll = "ls -l";
    la = "ls -a";
    lt = "ls --tree";
    lla ="ls -la";
  };
}
