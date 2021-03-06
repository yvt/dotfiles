import os.path as path
import os, sys

home = os.getenv("HOME")

dotfiles = path.dirname(path.dirname(path.dirname(path.abspath(__file__))))

prefixes = (
    "/",
    "/usr",
    "/usr/local",
    "/opt/local",
    "/run/current-system/sw",
)

prefixes = [p for p in prefixes if path.exists(p)]

executables = [path.join(prefix, "bin") for prefix in prefixes]
executables.append(path.join(home, "usr/bin"))
executables.append(path.join(home, ".rakudobrew/bin"))
executables.append(path.join(home, ".cargo/bin"))
# > And make sure that "~/.cabal/bin" comes *before* "~/.ghcup/bin"
# > in your PATH!
executables.append(path.join(home, ".cabal/bin"))
executables.append(path.join(home, ".ghcup/bin"))
executables.append(path.join(home, ".nix-profile/bin"))
executables.append(path.join(home, "Library/Haskell/bin"))
executables.append(path.join(dotfiles, "local", "bin"))
executables.append(path.join(dotfiles, "private", "bin"))
executables.append(path.join(dotfiles, "derived"))
executables.append(path.join(dotfiles, "bin"))

executables = [p for p in executables if path.exists(p)]

weak_executables = []
weak_executables.append("/opt/local/Library/Frameworks/Python.framework/Versions/2.7/bin")
weak_executables.append("/opt/local/Library/Frameworks/Python.framework/Versions/3.4/bin")
weak_executables.append("/opt/local/Library/Frameworks/Python.framework/Versions/3.6/bin")
weak_executables.append("/Library/Frameworks/Python.framework/Versions/2.7/bin")
weak_executables.append("/Library/Frameworks/Python.framework/Versions/3.4/bin")
weak_executables.append("/Library/Frameworks/Python.framework/Versions/3.6/bin")

weak_executables = [p for p in weak_executables if path.exists(p)]

# Unison file synchronizer (https://github.com/bcpierce00/unison)
if sys.platform == 'darwin':
    unison_data = path.join(home, 'Library/Application Support/Unison')
else:
    unison_data = path.join(home, '.unison')
