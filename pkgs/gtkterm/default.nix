{ lib, stdenv, fetchFromGitHub, glib, gtk3, meson, pkg-config, ninja, wrapGAppsHook, vte, libgudev, xz }:

stdenv.mkDerivation rec {
  pname = "gtkterm";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "Jeija";
    repo = "gtkterm";
    rev = "911105ad4fadd2af448483139316a0302ebd2dbb";
    sha256 = "9NjU5XyIv7liWuAtJWTNpkgIDKaXhEjzdNNlhqqHDGQ=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ meson ninja pkg-config wrapGAppsHook ];
  buildInputs = [ glib gtk3 vte libgudev ];
}
