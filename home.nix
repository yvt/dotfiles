{ pkgs, config, ... }:
with import <nixpkgs> {};
with builtins;
with lib;
with import <home-manager/modules/lib/dag.nix> { inherit lib; };

let
  isDarwin = hasSuffix "-darwin" currentSystem;
  home = config.home.homeDirectory;
  nixProfileBin = "${home}/.nix-profile/bin";
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

    # `stylesheet.css`
    ./modules/misc/stylesheet.nix
  ];

  programs.home-manager.enable = true;

  home.sessionVariables.LC_ALL = "en_US.UTF-8";

  programs.fish.loginShellInit =
      ''
      # Setup opam (OCaml package manager). It must be initialized
      # by `opam init` before use.
      source $HOME/.opam/opam-init/init.fish > /dev/null 2> /dev/null; or true
      '' +
    (optionalString isDarwin
      ''
      # configure PATH and other variables to use Nix
      source ${./fish/nix.fish}
      '');

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
    # remove `git` and `gitstage` because it confuses tmux. Also, it's slow.
    modules = [ "host" "nix-shell" "cwd" "perms" "root" ];
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
      rust-vim          # Rust <https://github.com/rust-lang/rust.vim>
      vim-lsp           # LSP support <https://github.com/prabirshrestha/vim-lsp>
    ];
    extraConfig =
      ''
      set shiftwidth=4
      set smartindent
      set nocompatible
      set backspace=2
      set maxmempattern=100000
      syntax on

      " always show status line
      set laststatus=2

      " always show tabline
      set showtabline=2

      " configurations for airline
      let g:airline_powerline_fonts=1
        let g:airline#extensions#tabline#enabled = 1

      " configurations for rust.vim
      let g:rustfmt_autosave = 1

      " vim-lsp
      if executable('rust-analyzer')
          au User lsp_setup call lsp#register_server({
            \   'name': 'Rust Language Server',
            \   'cmd': {server_info->['rust-analyzer']},
            \   'whitelist': ['rust'],
            \ })
      endif

      function! s:on_lsp_buffer_enabled() abort
          setlocal omnifunc=lsp#complete
          setlocal signcolumn=yes
          if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
          nmap <buffer> gd <plug>(lsp-definition)
          nmap <buffer> gs <plug>(lsp-document-symbol-search)
          nmap <buffer> gS <plug>(lsp-workspace-symbol-search)
          nmap <buffer> gr <plug>(lsp-references)
          nmap <buffer> gi <plug>(lsp-implementation)
          nmap <buffer> gt <plug>(lsp-type-definition)
          nmap <buffer> <leader>rn <plug>(lsp-rename)
          nmap <buffer> [g <plug>(lsp-previous-diagnostic)
          nmap <buffer> ]g <plug>(lsp-next-diagnostic)
          nmap <buffer> K <plug>(lsp-hover)
          inoremap <buffer> <expr><c-f> lsp#scroll(+4)
          inoremap <buffer> <expr><c-d> lsp#scroll(-4)

          let g:lsp_format_sync_timeout = 1000
          autocmd! BufWritePre *.rs,*.go call execute('LspDocumentFormatSync')

          " refer to doc to add more commands
      endfunction


      augroup lsp_install
        au!
        " call s:on_lsp_buffer_enabled only for languages that has the server registered.
        autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
      augroup END
      '';
  };

  programs.fish.interactiveShellInit =
    let
      # Force the use of a customized vim instead of a system-provided one
      vim = "${nixProfileBin}/vim";
    in
    ''
    not contains $EDITOR ${vim} subl; and set -x EDITOR ${vim}
    not contains $VISUAL ${vim} subl; and set -x VISUAL ${vim}
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

  # Applications
  # -------------------------------------------------------------------------
  home.packages = with pkgs; [
    gnupg
    htop
    jq
    mosh
    pandoc
    poetry
    ponysay
    python2
    python3
    ripgrep
    # rustup
    unzip
    p7zip
    wget
    whois
    pv
    gitSVN
    mercurial
    deno
    imagemagick7
    xz
    opam
    rlwrap
    zstd
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
    "${home}/.local/bin"
    "${home}/.dotnet/tools"
    "${home}/.nix-profile/bin"
    "${home}/Library/Haskell/bin"

    # `bin` in this dotfiles
    "${home}/.config/nixpkgs/bin"
    "${home}/.config/nixpkgs/private/bin"
    "${home}/.config/nixpkgs/local/bin"

    # iTerm2 utilities
    "${home}/.iterm2"
  ];

  home.paths = optionals (!isDarwin) [
    # Homebrew, MacPorts
    "/usr/local/bin"
    "/opt/local/bin"
  ];
}
