{ pkgs, config, ... }:
with import <nixpkgs> {};
with builtins;
with lib;
with import <home-manager/modules/lib/dag.nix> { inherit lib; };

let
  isDarwin = hasSuffix "-darwin" currentSystem;
  home = config.home.homeDirectory;
in

{
  imports = filter (e: e != null) [
    (if pathExists ./private/home.nix then ./private/home.nix else null)
    (if pathExists ./local/home.nix then ./local/home.nix else null)

    # Fancy shell prompt
    ./modules/programs/powerline-rs.nix

    # Fancy "ls"
    ./modules/programs/lsd.nix

    # Vim without GUI support, needed to support Darwin
    # (https://github.com/NixOS/nixpkgs/issues/47452)
    (if isDarwin then ./modules/programs/vim-nogui.nix else null)

    # Environment manager for Python
    ./modules/programs/pipenv.nix

    # File synchronizer
    ./modules/programs/unison.nix

    # Add `PATH`
    ./modules/misc/paths.nix
  ];

  programs.home-manager.enable = true;

  home.sessionVariables.LC_ALL = "en_US.UTF-8";

  # configure PATH and other variables to use Nix
  programs.fish.loginShellInit =
    if isDarwin then "source ${./fish/nix.fish}" else "";

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
    "jc" = "journalctl";
    "jc-x" = "journalctl -xe";
    "sc" = "systemctl";
    "sc-t" = "systemctl start";
    "sc-p" = "systemctl stop";
    "sc-r" = "systemctl restart";
    "sc-s" = "systemctl status";
  };

  programs.powerline-rs = {
    enable = true;
    modules = [ "host" "cwd" "perms" "git" "gitstage" "root" ];
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

  # Vim
  # -------------------------------------------------------------------------
  programs.vim = {
    enable = !isDarwin;
    plugins = with pkgs.vimPlugins; [
      sleuth            # tabstop heuristics
      airline           # fancy UI
      editorconfig-vim  # load tabstop configuration etc.
    ];
    extraConfig =
      ''
      set shiftwidth=4
      set smartindent
      set nocompatible
      set backspace=2
      syntax on

      " always show status line
      set laststatus=2

      " always show tabline
      set showtabline=2

      " configurations for airline
      let g:airline_powerline_fonts=1
      let g:airline#extensions#tabline#enabled = 1
      '';
  };

  programs.fish.interactiveShellInit =
    ''
    not contains $EDITOR vim subl; and set -x EDITOR vim
    not contains $VISUAL vim subl; and set -x VISUAL vim
    '';

  # tmux
  # -------------------------------------------------------------------------
  programs.tmux = {
    enable = true;
    terminal = "screen-256color";

    # Want the session to survive user logout
    secureSocket = false;

    plugins = [
      (callPackage ./pkgs/tmux-plugins/nord.nix {})
    ];
  };

  # TODO: check `EDITOR` variable
  # TODO: add PATHs

  # Applications
  # -------------------------------------------------------------------------
  home.packages = with pkgs; [
    gnupg
    htop
    jq
    mosh
    pandoc
    ponysay
    python2
    python3
    ripgrep
    rustup
    unzip
    wget
    whois
  ] ++ optionals (!isDarwin) [
    gcc
    gdb
    gnumake
  ];

  # Paths (`modules/misc/paths.nix`)
  # -------------------------------------------------------------------------
  home.strongPaths = [
    "${home}/.rakudobrew/bin"
    "${home}/.cargo/bin"
    "${home}/.cabal/bin"
    "${home}/.ghcup/bin"
    "${home}/.nix-profile/bin"
    "${home}/Library/Haskell/bin"

    # `bin` in this dotfiles
    "${home}/.config/nixpkgs/bin"
    "${home}/.config/nixpkgs/private/bin"
    "${home}/.config/nixpkgs/local/bin"
  ];

  home.paths = optionals (!isDarwin) [
    # Homebrew, MacPorts
    "/usr/local/bin"
    "/opt/local/bin"
  ];
}
