{ pkgs, ... }:
{
  home.packages = [ pkgs.pipenv ];

  programs.fish.interactiveShellInit =
    ''
    eval (env _PIPENV_COMPLETE=source-fish ${pkgs.pipenv}/bin/pipenv)
    '';
}
