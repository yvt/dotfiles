{ pkgs, ... }:
with import <nixpkgs> {};
with builtins;
with lib;
with import <home-manager/modules/lib/dag.nix> { inherit lib; };

let
  isDarwin = hasSuffix "-darwin" currentSystem;
in

{
  imports = filter (e: e != null) [
    (if pathExists ./private then ./private/home.nix else null)
    (if pathExists ./local then ./local/home.nix else null)

    ./modules/programs/powerline-rs.nix
    ./modules/programs/lsd.nix
  ];

  programs.home-manager.enable = true;

  programs.fish.enable = true;
  programs.fish.shellAbbrs = {
    "e" = "edit";
    "g-s" = "git status";
    "g-c" = "git commit";
    "gi" = "git issue";
    "gil" = "git issue list -l short";
  }
  // optionalAttrs (!isDarwin) {
    "-jc" = "journalctl";
    "jc-x" = "journalctl -xe";
    "-sc" = "systemctl";
    "sc-t" = "systemctl start";
    "sc-p" = "systemctl stop";
    "sc-r" = "systemctl restart";
    "sc-s" = "systemctl status";
  };

  # TODO: replace `TERM=screen` with `TERM=screen-256color`?
  # TODO: check `EDITOR` variable
  # TODO: add PATHs

  # configure PATH and other variables to use Nix
  programs.fish.loginShellInit =
    ''
      source ${./fish/nix.fish}
    '';
}
