{ pkgs, lib, config, ... }:

with lib;

let
  cfg = config.programs.unison;
  isDarwin = hasSuffix "-darwin" builtins.currentSystem;
in
{
  options.programs.unison = {
    enable = mkEnableOption "unison";

    enableX11 = mkOption {
      default = false;
      type = types.bool;
    };

    profiles = mkOption {
      default = {};
      example = {
        "name" =
          ''
          root = /localdir
          root = ssh://www.example.com/remotedir
          '';
      };
      type = types.attrs;
    };

    "profiles.*" = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ (pkgs.unison.override { enableX11 = cfg.enableX11; }) ];

    home.file =
    let
      profileFile = name:
        if isDarwin then
          "Library/Application Support/Unison/${name}.prf"
        else
          ".unison/${name}.prf";
    in
      mapAttrs'
        (name: text: nameValuePair (profileFile name) { text = text; })
        cfg.profiles;
  };
}
