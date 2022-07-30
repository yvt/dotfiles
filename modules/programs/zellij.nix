{ pkgs, lib, config, ... }:

let
  inherit (lib) mkIf mkOption types;
  cfg = config.programs.zellij;
  yamlFormat = pkgs.formats.yaml {};
in
{
  options.programs.zellij.layouts = mkOption {
    description = "Layouts to place in a generated layout directory.";
    default = {};
    example = types.attrsOf (types.oneOf [
      types.path
      yamlFormat.type
    ]);
  };

  options.programs.zellij.generateLayoutDir = mkOption {
    description = "Enables layout directory generation.";
    default = true;
    type = types.bool;
  };

  options.programs.zellij.themes = mkOption {
    description = "Themes to place in a generated theme directory.";
    default = {};
    example = types.attrsOf (types.oneOf [
      types.path
      yamlFormat.type
    ]);
  };

  options.programs.zellij.generateThemeDir = mkOption {
    description = "Enables theme directory generation. \
      Requires Zellij 0.31.0 or later.";
    default = true;
    type = types.bool;
  };

  options.programs.zellij.addExampleThemes = mkOption {
    description = "Specifies whether to add example themes to a generated \
      theme directory.";
    default = false;
    type = types.bool;
  };

  config.programs.zellij.settings =
    let
      generateLayoutDir =
        config.programs.zellij.generateLayoutDir &&
        config.programs.zellij.layouts != {};
      layoutsFlattened = lib.attrsets.mapAttrsToList
        (layoutName: layout: {
          name = layoutName;
          path = if builtins.isString layout
            then layout
            else yamlFormat.generate "zellij-layouts-${layoutName}" layout;
        })
        config.programs.zellij.layouts;
      layoutDir = pkgs.runCommand "zellij-layouts" {}
        (
          "mkdir -p $out\n" + 
          (lib.strings.concatMapStrings
            ({ name, path }: "ln -s '${path}' $out/'${name}.yaml'\n")
            layoutsFlattened));

      generateThemeDir =
        config.programs.zellij.generateThemeDir &&
        (config.programs.zellij.themes != {} ||
          config.programs.zellij.addExampleThemes);
      themesFlattened = lib.attrsets.mapAttrsToList
        (themeName: theme: {
          name = themeName;
          path = if builtins.isString theme
            then theme
            else yamlFormat.generate "zellij-themes-${themeName}" theme;
        })
        config.programs.zellij.themes;
      themeDir = pkgs.runCommand "zellij-themes" {}
        (
          "mkdir -p $out\n" + 
          (lib.strings.concatMapStrings
            ({ name, path }: "ln -s '${path}' $out/'${name}.yaml'\n")
            themesFlattened) +
          (lib.strings.optionalString
            config.programs.zellij.addExampleThemes
            ''
            cp '${config.programs.zellij.package.src}'/example/themes/*.yaml $out/
            ''));
    in {
      layout_dir = mkIf generateLayoutDir "${layoutDir}";
      theme_dir = mkIf generateThemeDir "${themeDir}";
    };
}
