import os
from .paths import prefixes, executables
import dotfiler.logger as log
import os.path as path

class Component(object):
    """A base class for component classes which inspect the availability or
       location of softwares installed on system.
    """
    def __init__(self):
        super(Component, self).__init__()
        self.exists = False
        self.messages = []
    def mark_found(self):
        self.exists = True
    def log(self, msg):
        self.messages.append(msg)
    def finalize(self):
        if not self.exists:
            log.warn(str(self) + ": The component was not found.")
            msgs = self.messages
            if len(msgs) > 0:
                log.notice("  Log messages:")
                for msg in msgs:
                    log.notice("    " + msg)

__loaded_components = {}

def get_component(comp_class):
    inst = __loaded_components.get(comp_class)
    if inst is None:
        inst = comp_class()
        __loaded_components[comp_class] = inst
        inst.finalize()
    return inst

get = lambda name: get_component(globals()[name])

class Executable(Component):
    def __init__(self, name):
        super(Executable, self).__init__()
        self.path = None
        self.name = name

    def search_standard_directories(self):
        for par_dir in executables:
            self.search_directory(par_dir)

    def search_directory(self, par_dir):
        if self.exists:
            return
        p = os.path.join(par_dir, self.name)
        if os.path.exists(p):
            if self.is_valid_file(p):
                self.path = p
                self.mark_found()
            else:
                self.log("'%s' was found, but detected as invalid." % p)
        else:
            self.log("'%s' was not found." % p)

    def is_valid_file(self, path):
        return True

    def __str__(self):
        return "Executable '%s'" % self.name

python_vers = ("2.7", "3.4")
python_pkg_dirs = [
    os.path.join(prefix, "lib", "python" + ver, sd + "-packages")
    for sd in ("site", "dist")
    for ver in python_vers
    for prefix in prefixes]
python_pkg_dirs += [
    os.path.join("/Library/Python/" + ver, sd + "-packages")
    for sd in ("site", "dist")
    for ver in python_vers]
python_pkg_dirs += [
    os.path.join("/Library/Frameworks/Python.framework/Versions/" + ver + "/lib/python" + ver, sd + "-packages")
    for sd in ("site", "dist")
    for ver in python_vers]
python_pkg_dirs += [
    os.path.join("/opt/local/Library/Frameworks/Python.framework/Versions/" + ver + "/lib/python" + ver, sd + "-packages")
    for sd in ("site", "dist")
    for ver in python_vers]

class PythonPackage(Component):
    """A base class for compoent classes which inspect the availabiliy of
       a python package (2.x or 3.x) located in site-package or dist-package.
    """
    def __init__(self, name):
        super(PythonPackage, self).__init__()
        self.path = None
        self.name = name

    def search_standard_package_directories(self):
        for pkg_par_dir in python_pkg_dirs:
            self.search_package_directory(pkg_par_dir)

    def search_package_directory(self, pkg_par_dir):
        if self.exists:
            return
        pkg_dir = os.path.join(pkg_par_dir, self.name)
        if os.path.exists(pkg_dir) and self.is_valid_package_path(pkg_dir):
            self.path = pkg_dir
            self.mark_found()
        else:
            self.log("'%s' was not found." % pkg_dir)

    def is_valid_package_path(self, pkg_path):
        return True

    def __str__(self):
        return "Python package '%s'" % self.name

class TermInfo(Component):
    def __init__(self, name):
        super(TermInfo, self).__init__()
        self.path = None
        self.name = name

    def search_standard_directories(self):
        for prefix in prefixes:
            self.search_directory(path.join(prefix, "share/terminfo"))
            self.search_directory(path.join(prefix, "lib/terminfo"))

    def search_directory(self, par_dir):
        if self.exists:
            return
        name = self.name

        fn = os.path.join(par_dir, name[0], name)
        if os.path.exists(fn):
            self.path = fn
            self.mark_found()
            return
        else:
            self.log("'%s' was not found." % fn)

        fn = os.path.join(par_dir, ("0" + hex(ord(name[0])))[-2:], name)
        if os.path.exists(fn):
            self.path = fn
            self.mark_found()
            return
        else:
            self.log("'%s' was not found." % fn)
    def __str__(self):
        return "Terminfo '%s'" % self.name

class Screen256ColorTermInfo(TermInfo):
    def __init__(self):
        super(Screen256ColorTermInfo, self).__init__('screen-256color')
        self.search_standard_directories()

class PowerlineDaemon(Executable):
    def __init__(self):
        super(PowerlineDaemon, self).__init__('powerline-daemon')
        self.search_standard_directories()

class PowerlineStatusPackage(PythonPackage):
    def __init__(self):
        super(PowerlineStatusPackage, self).__init__('powerline')
        self.bindings_path = None
        self.search_standard_package_directories()
        self.search_package_directory("/usr/share")

    def is_valid_package_path(self, pkg_path):
        if path.exists(path.join(pkg_path, "bindings")):
            self.bindings_path = path.join(pkg_path, "bindings")
            return True
        if path.exists(path.join(pkg_path, "fish")):
            self.bindings_path = path
            return True
        self.log("Bindings were not found for '%s'." % pkg_path)
        return False
