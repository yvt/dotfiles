with import <nixpkgs> {};
with lib;

let
  crossBuildPkgs = pkgsCross.riscv32-embedded.buildPackages;

in
runCommand "dummy" rec {
  nativeBuildInputs = [
    (crossBuildPkgs.gdb.override
      {
        # Work-around the error "C compiler cannot create executables"
        # on macOS
        safePaths = [ "$debugdir" "$datadir/auto-load" ];
      })
    (crossBuildPkgs.binutils.override
      {
        libc = null;
        noLibc = true;
      })
  ];
} ""
