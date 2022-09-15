{ pkgs, config, ... }:
with import <nixpkgs> {};
with builtins;
with lib;
with import <home-manager/modules/lib/dag.nix> { inherit lib; };

let
  isDarwin = hasSuffix "-darwin" currentSystem;
  isDarwinAArch64 = isDarwin && hasPrefix "aarch64-" currentSystem;
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

    # Override packages unsupported in aarch64-apple-darwin
    (if isDarwinAArch64 then ./modules/misc/darwin-intel.nix else null)

    # Environment manager for Python
    ./modules/programs/pipenv.nix

    # File synchronizer
    ./modules/programs/unison.nix

    # Add `PATH`
    ./modules/misc/paths.nix

    # `stylesheet.css`
    ./modules/misc/stylesheet.nix

    # Terminal workspace
    ./modules/programs/zellij.nix
  ];

  programs.home-manager.enable = true;

  home.sessionVariables.LC_ALL = "en_US.UTF-8";

  programs.fish.loginShellInit =
      ''
      # Setup opam (OCaml package manager). It must be initialized
      # by `opam init` before use.
      # FIXME: Doesn't support Fish 3.4
      # source $HOME/.opam/opam-init/init.fish > /dev/null 2> /dev/null; or true
      '' +
    (optionalString isDarwin
      ''
      # configure PATH and other variables to use Nix
      source ${./fish/nix.fish}
      '');

  programs.zsh.initExtra =
    (optionalString isDarwin
      ''
      # configure PATH and other variables to use Nix
      . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
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

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    enableSyntaxHighlighting = true;
    autocd = true;
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
      editor = "${config.programs.helix.package}/bin/hx";
    in
    ''
    not contains $EDITOR ${vim} subl ${editor}; and set -x EDITOR ${editor}
    not contains $VISUAL ${vim} subl ${editor}; and set -x VISUAL ${editor}
    '';

  # Helix
  # -------------------------------------------------------------------------
  programs.helix = {
    enable = true;
    settings = {
      theme = "dark_plus";
      editor.idle-timeout = 100;
      editor.line-number = "relative";
      editor.rulers = [ 75 80 100 ];
      editor.indent-guides.render = true;
      editor.indent-guides.character = "▏";
    };
    languages = [
      {
        name = "rust";
        language-server = { command = "${./bin/rustup-rust-analyzer}"; };
      }
    ];
  };

  # tmux
  # -------------------------------------------------------------------------
  programs.tmux = {
    enable = true;
    terminal = "screen-256color";

    # Want the session to survive user logout
    secureSocket = false;

    # Handle Escape quickly
    escapeTime = 100;

    extraConfig = ''
      # Enable true colors on `xterm-256color*`
      set -ga terminal-overrides ",xterm-256color*:Tc"
    '';

    plugins = [
      (callPackage ./pkgs/tmux-plugins/nord.nix {})
    ];
  };

  # Zellij
  # -------------------------------------------------------------------------
  programs.zellij = {
    enable = true;
  
    settings.pane_frames = false;
    settings.mirror_session = true;

    # TODO: `theme_dir` requires Zellij 0.31.0 or later
    # addExampleThemes = true;
    settings.theme = "nord";
    settings.themes.nord = {
      fg = [ 216 222 233 ]; #D8DEE9
      bg = [ 46 52 64 ]; #2E3440
      black = [ 59 66 82 ]; #3B4252
      red = [ 191 97 106 ]; #BF616A
      green = [ 163 190 140 ]; #A3BE8C
      yellow = [ 235 203 139 ]; #EBCB8B
      blue = [ 129 161 193 ]; #81A1C1
      magenta = [ 180 142 173 ]; #B48EAD
      cyan = [ 136 192 208 ]; #88C0D0
      white = [ 229 233 240 ]; #E5E9F0
      orange = [ 208 135 112 ]; #D08770
    };

    # Replace the key binding for "quit"
    settings.keybinds.unbind = [ { Ctrl = "q"; } ];
    settings.keybinds.session = [
      {
        action = [ "Quit" ];
        key = [ { Char = "q"; } ];
      }
    ];
  };

  # Git
  # -------------------------------------------------------------------------
  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;

    # Structural diff <https://github.com/Wilfred/difftastic>
    difftastic = {
      enable = true;
      background = "dark";
    };

    extraConfig = {
      # Don't create a merge commit on `git pull`
      pull.ff = "only";

      # Initial branch name
      init.defaultBranch = "main";

      # <https://www.michaelheap.com/git-ignore-rev/>
      # Load the list of blame-exempt commits as per convention
      blame.ignoreRevsFile = ".git-blame-ignore-revs";
      # Mark any lines that have had a commit skipped using --ignore-rev with a
      # `?`
      blame.markIgnoredLines = true;
      # Mark any lines that were added in a skipped commit and can not be
      # attributed with a `*`
      blame.markUnblamableLines = true;
    };
  };

  programs.gitui = {
    enable = true;
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
    fd
    socat
    rustup
    unzip
    p7zip
    wget
    whois
    pv
    mercurial
    deno
    imagemagick7
    xz
    opam
    rlwrap
    zstd
    file
    openssh
    torsocks
    tagref
    b3sum
    srm
    unrar
    ffmpeg
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
    "/nix/var/nix/profiles/default/bin"

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
