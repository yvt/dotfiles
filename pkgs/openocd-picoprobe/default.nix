{ stdenv
, lib
, fetchFromGitHub
, pkg-config
, hidapi
, libftdi1
, libusb1
, libtool
, which
, autoconf
, automake
}:

stdenv.mkDerivation rec {
  pname = "openocd";
  version = "0.11.0";
  src = fetchFromGitHub {
    owner = "raspberrypi";
    repo = "openocd";
    rev = "610f137d2b91b794dc9a8999b1e6631a99fcddc7";
    sha256 = "yeXAN5kd4ycxl98KX7JbxPOet26TN5P50fbHuPGrSFw=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ pkg-config libtool which autoconf automake ];

  buildInputs = [ hidapi libftdi1 libusb1 ];

  configureFlags = [
    "--enable-jtag_vpi"
    "--enable-usb_blaster_libftdi"
    (lib.enableFeature (! stdenv.isDarwin) "amtjtagaccel")
    (lib.enableFeature (! stdenv.isDarwin) "gw16012")
    "--enable-presto_libftdi"
    "--enable-openjtag_ftdi"
    (lib.enableFeature (! stdenv.isDarwin) "oocd_trace")
    "--enable-buspirate"
    (lib.enableFeature stdenv.isLinux "sysfsgpio")
    "--enable-remote-bitbang"
  ];

  NIX_CFLAGS_COMPILE = lib.optionals stdenv.cc.isGNU [
    "-Wno-error=cpp"
    "-Wno-error=strict-prototypes" # fixes build failure with hidapi 0.10.0
  ];

  SKIP_SUBMODULE = 1;

  patches = [ ./libjaylink-libtool.patch ];

  preConfigure = ''
    # `src/jtag/drivers/libjaylink/autogen.sh` defaults to glibtoolize on
    # Darwin, so we patch it to use the correct command.


    SKIP_SUBMODULE=1 ./bootstrap
  '';

  postInstall = lib.optionalString stdenv.isLinux ''
    mkdir -p "$out/etc/udev/rules.d"
    rules="$out/share/openocd/contrib/60-openocd.rules"
    if [ ! -f "$rules" ]; then
        echo "$rules is missing, must update the Nix file."
        exit 1
    fi
    ln -s "$rules" "$out/etc/udev/rules.d/"
  '';

  meta = with lib; {
    description = "Free and Open On-Chip Debugging, In-System Programming and Boundary-Scan Testing";
    longDescription = ''
      OpenOCD provides on-chip programming and debugging support with a layered
      architecture of JTAG interface and TAP support, debug target support
      (e.g. ARM, MIPS), and flash chip drivers (e.g. CFI, NAND, etc.).  Several
      network interfaces are available for interactiving with OpenOCD: HTTP,
      telnet, TCL, and GDB.  The GDB server enables OpenOCD to function as a
      "remote target" for source-level debugging of embedded systems using the
      GNU GDB program.
    '';
    homepage = "https://openocd.sourceforge.net/";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ bjornfor prusnak ];
    platforms = platforms.unix;
  };
}
