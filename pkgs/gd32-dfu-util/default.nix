{ stdenv, fetchFromGitHub, pkgconfig, libusb1 }:

stdenv.mkDerivation rec {
  pname = "gd32-dfu-util";
  version = "0.9";

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ libusb1 ];

  src = fetchFromGitHub {
    owner = "riscv-mcu";
    repo = "gd32-dfu-utils";
    rev = "c2c8215061b08146e6a4c8c22bc57fae95c656df";
    sha256 = "0hyzbwx29qws5bpp3gw161z6x1bacsnq1lw0v5ja8z4nr9mj9ds7";
  };

  meta = with stdenv.lib; {
    description = "Device firmware update (DFU) USB programmer, patched for GD32";
    longDescription = ''
      dfu-util is a program that implements the host (PC) side of the USB
      DFU 1.0 and 1.1 (Universal Serial Bus Device Firmware Upgrade) protocol.
      DFU is intended to download and upload firmware to devices connected over
      USB. It ranges from small devices like micro-controller boards up to mobile
      phones. With dfu-util you are able to download firmware to your device or
      upload firmware from it.
    '';
    homepage = https://github.com/riscv-mcu/gd32-dfu-utils;
    license = licenses.gpl2Plus;
    platforms = platforms.unix;
    maintainers = [ maintainers.yvt ];
  };
}
