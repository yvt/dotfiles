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

    # Fancy shell prompt
    ./modules/programs/powerline-rs.nix

    # Fancy "ls"
    ./modules/programs/lsd.nix
  ];

  programs.home-manager.enable = true;

  # configure PATH and other variables to use Nix
  programs.fish.loginShellInit =
    ''
      source ${./fish/nix.fish}
    '';

  # Shells
  # -------------------------------------------------------------------------
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

  # SSH Client
  # -------------------------------------------------------------------------
  programs.ssh = {
    enable = true;
    extraConfig =
      ''
      Host *
        ServerAliveInterval 60
        ServerAliveCountMax 1440
      '';
  };

  # TODO: replace `TERM=screen` with `TERM=screen-256color`?
  # TODO: check `EDITOR` variable
  # TODO: add PATHs

  # Applications
  # -------------------------------------------------------------------------
  home.packages = with pkgs; [
    gcc
    gdb
    gnumake
    gnupg
    htop
    jq
    mosh
    pandoc
    ponysay
    ripgrep
    tmux
    unzip
    wget
    whois
  ];
}
