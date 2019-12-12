{ pkgs, lib, config, ... }:

with lib;

let
  cfg = config.programs.powerline-rs;
in
{
  options.programs.powerline-rs = {
    enable = mkEnableOption "powerline-rs";

    modules = mkOption {
      description = "The list of modules to load";
      default = [ "ssh" "cwd" "perms" "git" "gitstage" "root" ];
      type = types.listOf types.str;
    };
  };

  config = mkIf cfg.enable {
    programs.fish.promptInit =
      let
        modules = concatStringsSep "," cfg.modules;
      in
        ''
        function fish_prompt
          ${pkgs.powerline-rs}/bin/powerline-rs --shell bare $status --modules '${modules}'
        end
        '';
    # TODO: zsh, bash
  };
}
