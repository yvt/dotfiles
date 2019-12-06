{ pkgs, lib, ... }:

with lib;

let
  stdenv = (import <nixpkgs> {}).stdenv;

  pipenvFishAutocompletion = stdenv.mkDerivation {
    name = "pipenv-fish-completion";
    dontUnpack = true;
    buildInputs = [ pkgs.pipenv ];
    buildPhase = ''
      _PIPENV_COMPLETE=source-fish pipenv > setenv.fish
    '';
    installPhase = ''
      mkdir -p $out/bin
      cp setenv.fish $out/bin
    '';
  };
in
{
  home.packages = [ pkgs.pipenv ];

  programs.fish.interactiveShellInit =
    replaceStrings ["pipenv)"] ["${pkgs.pipenv}/bin/pipenv)"]
      (readFile "${pipenvFishAutocompletion}/bin/setenv.fish");
}
