{ pkgs, lib, config, ... }:

let
  inherit (builtins)
    match
    substring
    stringLength
    head
    tail
    map
    filter;
  inherit (lib)
    assertMsg
    concatStringsSep
    flatten
    literalExample
    mkOption
    mkIf
    mapNullable
    options
    optionalString
    types
    unique
    splitString;

  cfg = config.home.stylesheet;
in
{
  options.home.stylesheet.enable = mkOption {
    description = "Enables the generation of the `~/.local/stylesheet.cs` file.";
    default = false;
    type = types.bool;
  };

  options.home.stylesheet.extraConfig = mkOption {
    description = "Adds given text to the stylesheet.";
    default = "";
    example = [ "* { display: none }" ];
    type = types.lines;
  };

  options.home.stylesheet.searchResultBlacklist = mkOption {
    description = ''
      Hides (but does not completely removes) the specified domains
      in DuckDuckGo search results.
    '';
    default = [];
    example = [ "*.example.com" ];
    type = types.listOf types.str;
  };

  options.home.stylesheet.searchResultBlacklistByUBlacklist = mkOption {
    description = ''
      Hides (but does not completely removes) the specified domains
      in DuckDuckGo search results. Specified in the uBlacklist format.
      Only the lines matching the regex
      <code>/^(\*|http|https):\/\/(.*)/\*$/</code> are processed and the rest
      are ignored silently.
    '';
    default = "";
    example = literalExample ''
      "*://*.example.com/*\n"
      + (readFile (fetchurl {
        url = "https://raw.githubusercontent.com/sfsef/uBlacklist-subscription/f922de8902986629042ef962cc9825c1a6b672e0/blocklist.txt";
        sha256 = "1bcykyajla2r66cpyfiag24y6kin3rdrp75mps7i39nwqj6wacf8";
      }))
    '';
    type = types.lines;
  };

  config = mkIf cfg.enable (
    let
      /* Extract valid entries from a given uBlacklist blacklist to use with
        `home.stylesheet.searchResultBlacklist`. */
      parseUBlacklist = text:
        let
          lines = splitString "\n" text;
        in
          filter (line: line != null)
            (map (line:
              mapNullable
                (matchResult: head (tail matchResult))
                (match "(\\*|http|https)://(.*)/\\*\r?" line)) lines);

      searchResultBlacklist = unique
        (cfg.searchResultBlacklist
          ++ (parseUBlacklist cfg.searchResultBlacklistByUBlacklist));

      duckBlacklistSelectors = flatten (map (pattern:
        let
          anyPrefix = (pattern != "") && ((substring 0 1 pattern) == "*");
          anySuffix = (pattern != "") && ((substring (stringLength pattern - 1) 1 pattern) == "*");
          pattern2 = if anyPrefix then substring 1 (stringLength pattern - 1) pattern else pattern;
          pattern3 = if anySuffix then substring 0 (stringLength pattern2 - 1) pattern2 else pattern2;

          resultSelector =
            assert assertMsg (builtins.match ".*\\*.*" pattern3 == null)
              "The element `${pattern}` of `home.stylesheet.searchResultBlacklist` ${
                ""}cannot be expressed by a CSS selector.";
            if anyPrefix && anySuffix then
              "div.result[data-domain*=\"${pattern3}\"]"
            else if anySuffix then
              "div.result[data-domain^=\"${pattern3}\"]"
            else if anyPrefix then
              "div.result[data-domain$=\"${pattern3}\"]"
            else
              "div.result[data-domain=\"${pattern3}\"]";

          in [resultSelector (resultSelector + " + .results__sitelink--organics")]
        ) searchResultBlacklist);

      duckBlacklistConfig =
        optionalString (duckBlacklistSelectors != []) (
          (concatStringsSep ",\n" duckBlacklistSelectors)
          + ''
             {
              opacity: 0.1;
            }

            div.result[data-domain]:hover,
            div.result[data-domain] + .results__sitelink--organics:hover { opacity: 1 !important; }
          ''
        );

    in {
      home.file.".local/stylesheet.css".text =
        ''
          /* This file was @generated automatically by Home Manager */
          ${duckBlacklistConfig}
          ${cfg.extraConfig}
        '';
    });
}
