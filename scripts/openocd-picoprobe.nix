with import <nixpkgs> {};
with lib;

runCommand "dummy" rec {
  nativeBuildInputs = [
    (callPackage ../pkgs/openocd-picoprobe {})
  ];
} ""
