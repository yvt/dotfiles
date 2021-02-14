{ stdenv, lib, rustPlatform, fetchFromGitHub, libudev, pkgconfig }:

rustPlatform.buildRustPackage rec {
  pname = "elf2uf2-rs";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "JoNil";
    repo = pname;
    rev = "67dc449da0e19c74ecbbae1a5bb02787253eaf67";
    sha256 = "1g377fqvrbfjci9j6zacn97kzia4kj3xm7ibyq4xshsyz1nj4cll";
  };

  cargoSha256 = "1rdpy8755f47r3hpj11z50q91nw48g4zqhmigm27sdki2a6x85hz";

  nativeBuildInputs = lib.optionals stdenv.isLinux [ pkgconfig ];
  buildInputs = lib.optionals stdenv.isLinux [ libudev ];
}

