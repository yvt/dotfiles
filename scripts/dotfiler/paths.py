import os.path as path
import os
from dotfiler.nix import get_derivation_out_path

home = os.getenv("HOME")

dotfiles = path.dirname(path.dirname(path.dirname(path.abspath(__file__))))

prefixes = (
    "/",
    "/usr",
    "/usr/local",
    "/opt/local"
)

prefixes = [p for p in prefixes if path.exists(p)]

def get_prefixes(nix_pkgs=[]):
    """ Get a set of prefixes using additional options.

        - nix_pkgs: Zero or more NixOS derivation attribute names.
    """
    ret = prefixes[:]
    
    ret += filter(lambda x: x is not None,
        [get_derivation_out_path(x) for x in nix_pkgs])

    return ret


executables = [path.join(prefix, "bin") for prefix in prefixes]
executables += [path.join(prefix, "sbin") for prefix in prefixes]
executables.append(path.join(home, "usr/bin"))
executables.append(path.join(home, ".rakudobrew/bin"))
executables.append(path.join(home, ".cargo/bin"))
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
