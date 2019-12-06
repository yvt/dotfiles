{ pkgs, ... }:
{
  programs.fish.promptInit =
    ''
    function fish_prompt
      ${pkgs.powerline-rs}/bin/powerline-rs --shell bare $status
    end
    '';
}
