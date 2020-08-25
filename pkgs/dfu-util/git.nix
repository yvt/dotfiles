{ stdenv, fetchgit, pkgconfig, libusb1, autoreconfHook }:

stdenv.mkDerivation rec {
  pname = "dfu-util-git";
  version = "0.9-17910d7";

  nativeBuildInputs = [ pkgconfig autoreconfHook ];
  buildInputs = [ libusb1 ];

  src = fetchgit {
      url = "git://git.code.sf.net/p/dfu-util/dfu-util";
      rev = "17910d73867e1f22d5fe9b028350e23773686dd6";
      sha256 = "0c047cjk10wwpf7pniah96g7psplig6jk0mnk8cjd1c53g7c7qbv";
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
