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

  cargoSha256 = "01j40z83vzl11v5zw8is0r3v7f4mqb6m3wwzw0fib1acixhl8692";

  nativeBuildInputs = lib.optionals stdenv.isLinux [ pkgconfig ];
  buildInputs = lib.optionals stdenv.isLinux [ libudev ];
}

