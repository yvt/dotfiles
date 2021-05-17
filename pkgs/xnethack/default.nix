# based on <https://github.com/NixOS/nixpkgs/blob/f63d83696aab040b1e9c08bc22defec8e9a30626/pkgs/games/nethack/default.nix>
{ stdenv, lib, fetchFromGitHub, coreutils, ncurses, gzip, flex, bison, groff, unixtools
, less
, buildPackages
, x11Mode ? false, qtMode ? false, libXaw, libXext, libXpm, bdftopcf, mkfontdir, pkg-config, qt5
}:

let
  platform =
    if stdenv.hostPlatform.isUnix then "unix"
    else throw "Unknown platform for NetHack: ${stdenv.hostPlatform.system}";
  unixHint =
    if x11Mode then "linux-x11" # TODO: remove?
    else if qtMode then "linux-qt4" # TODO: remove?
    else if stdenv.hostPlatform.isLinux  then "linux.2020"
    else if stdenv.hostPlatform.isDarwin then "macOS.2020"
    # We probably want something different for Darwin
    else "unix";
  userDir = "~/.config/xnethack";
  binPath = lib.makeBinPath [ coreutils less ];

in stdenv.mkDerivation rec {
  version = "5.1.3";
  name = if x11Mode then "xnethack-x11-${version}"
         else if qtMode then "xnethack-qt-${version}"
         else "xnethack-${version}";

  src = fetchFromGitHub {
    owner = "copperwater";
    repo = "xNetHack";
    rev = "287d658b1fc18f8528439a8383b589f508973c08";
    sha256 = "15kwvd8c3dpbv5lfffhlabs48mm72iy5sqa0c5l02ghvqqjga585";
    fetchSubmodules = true;
  };

  buildInputs = [ ncurses ]
                ++ lib.optionals x11Mode [ libXaw libXext libXpm ]
                ++ lib.optionals qtMode [ gzip qt5.qtbase.bin qt5.qtmultimedia.bin ];

  nativeBuildInputs = [ flex bison groff unixtools.col ]
                      ++ lib.optionals x11Mode [ mkfontdir bdftopcf ]
                      ++ lib.optionals qtMode [
                           pkg-config mkfontdir qt5.qtbase.dev
                           qt5.qtmultimedia.dev qt5.wrapQtAppsHook
                           bdftopcf
                         ];

  makeFlags = [ "PREFIX=$(out)" "WANT_WIN_CURSES=1" ];

  postPatch = ''
    sed -e '/^ *cd /d' -i sys/unix/nethack.sh
    sed \
      -e 's/^YACC *=.*/YACC = bison -y/' \
      -e 's/^LEX *=.*/LEX = flex/' \
      -i sys/unix/Makefile.utl
    sed \
      -e 's,^WINQT4LIB =.*,WINQT4LIB = `pkg-config Qt5Gui --libs` \\\
            `pkg-config Qt5Widgets --libs` \\\
            `pkg-config Qt5Multimedia --libs`,' \
      -i sys/unix/Makefile.src
    sed \
      -e 's,^CFLAGS=-g,CFLAGS=,' \
      -e 's,/bin/gzip,${gzip}/bin/gzip,g' \
      -e 's,^WINTTYLIB=.*,WINTTYLIB=-lncurses,' \
      -i sys/unix/hints/linux.2020
    sed \
      -e 's,^CC=.*$,CC=cc,' \
      -e 's,^HACKDIR=.*$,HACKDIR=\$(PREFIX)/games/lib/\$(GAME)dir,' \
      -e 's,^SHELLDIR=.*$,SHELLDIR=\$(PREFIX)/games,' \
      -e 's,^WANT_BUNDLE=1,,' \
      -e 's,^CCFLAGS = -g,CCFLAGS = -g -fsanitize=address -fsanitize=undefined,' \
      -i sys/unix/hints/macOS.2020
    echo 'LFLAGS := $(LFLAGS) -fsanitize=address -fsanitize=undefined' >> sys/unix/hints/macOS.2020
    sed -e '/define CHDIR/d' -i include/config.h
    ${lib.optionalString qtMode ''
    sed \
      -e 's,^QTDIR *=.*,QTDIR=${qt5.qtbase.dev},' \
      -e 's,CFLAGS.*QtGui.*,CFLAGS += `pkg-config Qt5Gui --cflags`,' \
      -e 's,CFLAGS+=-DCOMPRESS.*,CFLAGS+=-DCOMPRESS=\\"${gzip}/bin/gzip\\" \\\
        -DCOMPRESS_EXTENSION=\\".gz\\",' \
      -e 's,moc-qt4,moc,' \
      -i sys/unix/hints/linux-qt4
    ''}
    ${lib.optionalString (stdenv.buildPlatform != stdenv.hostPlatform)
    # If we're cross-compiling, replace the paths to the data generation tools
    # with the ones from the build platform's nethack package, since we can't
    # run the ones we've built here.
    ''
    ${buildPackages.perl}/bin/perl -p \
      -e 's,[a-z./]+/(makedefs|dgn_comp|lev_comp|dlb)(?!\.),${buildPackages.xnethack}/libexec/nethack/\1,g' \
      -i sys/unix/Makefile.*
    ''}
    sed -i -e '/rm -f $(MAKEDEFS)/d' sys/unix/Makefile.src
    mkdir -p lib/lua-5.4.2
    ln -s ../../submodules/lua lib/lua-5.4.2/src
  '';

  configurePhase = ''
    pushd sys/${platform}
    ${lib.optionalString (platform == "unix") ''
      sh setup.sh hints/${unixHint}
    ''}
    popd
  '';

  # Parallel building causes the guide to be built before its prerequisite
  # `makedefs`
  enableParallelBuilding = false;

  preFixup = lib.optionalString qtMode ''
    wrapQtApp "$out/games/xnethack"
  '';

  postInstall = ''
    mkdir -p $out/games/lib/nethackuserdir
    for i in xlogfile logfile perm record save; do
      mv $out/games/lib/xnethackdir/$i $out/games/lib/nethackuserdir
    done

    mkdir -p $out/bin
    cat <<EOF >$out/bin/xnethack
    #! ${stdenv.shell} -e
    PATH=${binPath}:\$PATH

    if [ ! -d ${userDir} ]; then
      mkdir -p ${userDir}
      cp -r $out/games/lib/nethackuserdir/* ${userDir}
      chmod -R +w ${userDir}
    fi

    RUNDIR=\$(mktemp -d)

    cleanup() {
      rm -rf \$RUNDIR
    }
    trap cleanup EXIT

    cd \$RUNDIR
    for i in ${userDir}/*; do
      ln -s \$i \$(basename \$i)
    done
    for i in $out/games/lib/xnethackdir/*; do
      ln -s \$i \$(basename \$i)
    done
    $out/games/xnethack "\$@"
    EOF
    chmod +x $out/bin/xnethack
    ${lib.optionalString x11Mode "mv $out/bin/xnethack $out/bin/xnethack-x11"}
    ${lib.optionalString qtMode "mv $out/bin/xnethack $out/bin/xnethack-qt"}
    ${lib.optionalString (!(x11Mode || qtMode)) "install -Dm 555 util/dlb -t $out/libexec/xnethack/"}
  '';

  meta = with lib; {
    description = "Rogue-like game";
    homepage = "https://github.com/copperwater/xNetHack";
    license = "nethack";
    platforms = if x11Mode then platforms.linux else platforms.unix;
    maintainers = with maintainers; [ yvt abbradar ];
  };
}
