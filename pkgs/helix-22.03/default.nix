# <https://github.com/NixOS/nixpkgs/blob/7e2559da3618d78f896317ede0e8f2d7142c9db9/pkgs/applications/editors/helix/default.nix>
{ fetchzip, stdenv, lib, makeRustPlatform, makeWrapper }:

let
  fenix = import (fetchTarball "https://github.com/nix-community/fenix/archive/2263c2111988cc5e80520225ad16afc98c22a494.tar.gz") { };
  rustPlatform = makeRustPlatform {
    inherit (fenix.stable) cargo rustc;
  };

in
rustPlatform.buildRustPackage rec {
  pname = "helix";
  version = "22.03";

  # This release tarball includes source code for the tree-sitter grammars,
  # which is not ordinarily part of the repository.
  src = fetchzip {
    url = "https://github.com/helix-editor/helix/releases/download/${version}/helix-${version}-source.tar.xz";
    sha256 = "DP/hh6JfnyHdW2bg0cvhwlWvruNDvL9bmXM46iAUQzA=";
    stripRoot = false;
  };

  cargoSha256 = "zJQ+KvO+6iUIb0eJ+LnMbitxaqTxfqgu7XXj3j0GiX4=";

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    # not needed at runtime
    rm -r runtime/grammars/sources

    mkdir -p $out/lib
    cp -r runtime $out/lib
  '';
  postFixup = ''
    wrapProgram $out/bin/hx --set HELIX_RUNTIME $out/lib/runtime
  '';

  meta = with lib; {
    description = "A post-modern modal text editor";
    homepage = "https://helix-editor.com";
    license = licenses.mpl20;
    mainProgram = "hx";
    maintainers = with maintainers; [ danth yusdacra ];
  };
}
