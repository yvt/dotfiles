{ pkgs, lib, config, ... }:

with lib;

let
  cfg = config.home;
in
{
  options.home.paths = mkOption {
    description = "Adds given paths to PATH after existing paths.";
    default = {};
    example = [ "/usr/local/bin" ];
    type = types.listOf types.str;
  };
  options.home.strongPaths = mkOption {
    description = "Adds given paths to PATH before existing paths.";
    default = {};
    example = [ "/usr/local/bin" ];
    type = types.listOf types.str;
  };
  config = {
    programs.fish.interactiveShellInit =
      ''
      function add_path
        set ADDED_PATH $argv[1]
        if [ ! -x $ADDED_PATH ]; return; end
        not contains $ADDED_PATH $PATH
          and set -x PATH $ADDED_PATH $PATH
      end

      function add_path_weak
        set ADDED_PATH $argv[1]
        if [ ! -x $ADDED_PATH ]; return; end
        not contains $ADDED_PATH $PATH
          and set -x PATH $PATH $ADDED_PATH
      end
      '' +
      (concatStrings (map (p: "add_path '${p}'\n") cfg.strongPaths)) +
      (concatStrings (map (p: "add_path_weak '${p}'\n") cfg.paths));
    # TODO: bash, zsh
  };
}