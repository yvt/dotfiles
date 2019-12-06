{ pkgs, lib, config, ... }:

with lib;

let
  cfg = config.programs.vim;

  # TODO: `cfg.settings`
  customRC = ''
    ${cfg.extraConfig}
  '';

  vim_configurable = pkgs.vim_configurable.overrideAttrs (oa:
    {
      configureFlags = lib.filter
        (f: ! lib.hasPrefix "--enable-gui" f) oa.configureFlags;
    });

  vim = vim_configurable.customize {
    name = "vim";
    vimrcConfig = {
      inherit customRC;

      packages.home-manager.start = cfg.plugins;
    };
  };
in
{
  assertions = [
    {
      assertion = !cfg.enable;
      message = "Please disable `programs.vim.enable` or both versions " +
        "(with GUI and without GUI) will be installed";
    }
  ];

  home.packages = [ vim ];
}
