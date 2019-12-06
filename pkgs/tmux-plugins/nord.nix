{ fetchgit, stdenv, ... }:

let
  rtpPath = "share/tmux-plugins/nord";

  derivation = stdenv.mkDerivation {
    name = "tmuxplugin-nord";
    pluginName = "nord";
    src = fetchgit {
      url = "https://github.com/arcticicestudio/nord-tmux";
      rev = "25c64f5fc4ff716fae7256d9a8f6af4724644edc";
      sha256 = "14xhh49izvjw4ycwq5gx4if7a0bcnvgsf3irywc3qps6jjcf5ymk";
    };
    installPhase = ''
      target=$out/${rtpPath}
      mkdir -p $out/${rtpPath}
      cp -r . $target
    '';
  };
in
  derivation // { rtp = "${derivation}/${rtpPath}/nord.tmux"; }
