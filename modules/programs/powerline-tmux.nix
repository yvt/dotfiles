{ pkgs, ... }:

let
  powerline = pkgs.python37Packages.powerline;
in
{
  programs.tmux = {
    extraConfig =
      ''
      run-shell "powerline-daemon -q"
      source "${powerline}/lib/python3.7/site-packages/powerline/bindings/tmux/powerline.conf"
      '';
  };

  # `powerline-config` command should be available
  home.packages = [ powerline ];
}
