#!/usr/bin/env python

import os, sys, shutil, errno
import os.path as path
from optparse import OptionParser
from texthon.engine import Engine
from texthon.parser import Parser
import dotfiler.logger as log
import dotfiler.paths as paths

base_path = paths.dotfiles

# is the location of `.dotfiles` valid?
home_dir = os.getenv('HOME')
expected_path = path.realpath(path.join(home_dir, ".dotfiles"))
actual_path = path.realpath(base_path)
if expected_path != actual_path:
    log.fatal("The location of '.dotfiles' is invalid.")
    log.notice("  Expected: " + expected_path)
    log.notice("  Got: " + actual_path)
    sys.exit()

os.chdir(base_path)
paths.dotfiles = base_path

# Parse options
parser = OptionParser()
parser.add_option("-v", "--verbose", action="store_true", dest="verbose", default=False,
    help="be verbose")
(options, args) = parser.parse_args()

if options.verbose:
    log.notice_enabled = True

def mkdirp(task_name, path):
    try:
        os.makedirs(path)
        log.success("%s: mkdirp: %s" % (task_name, path))
    except OSError as exc:
        if exc.errno == errno.EEXIST and os.path.isdir(path):
            log.notice("%s: mkdirp: '%s' already exists." % (task_name, path))
        else:
            raise

def exec_cmd(task_name, cmd):
    log.notice("%s: exec: %s" % (task_name, cmd))
    ret = system("git clone ")
    if ret != 0:
        log.error("%s: command '%s' failed with error code %d." % (task_name, cmd, ret))

def git_clone(task_name, fs_path, repo):
    if path.exists(fs_path):
        log.notice("%s: git-clone: '%s' already exists." % (task_name, fs_path))
        return
    exec_cmd(task_name, 'git clone "%s" "%s"' % (repo, fs_path))

def mklink(task_name, to_path, from_path):
    if path.exists(from_path):
        log.notice("%s: symlink: '%s' already exists." % (task_name, from_path))
        return
    os.symlink(to_path, from_path)
    log.success("%s: symlink: %s --> %s" % (task_name, from_path, to_path))

def copy_no_overwrite(task_name, orig_path, out_path):
    if path.exists(out_path):
        log.notice("%s: copy: '%s' already exists." % (task_name, out_path))
        return
    os.copy(orig_path, out_path)
    log.success("%s: copy: %s --> %s" % (task_name, orig_path, out_path))

def per_line_patch(task_name, path, added_lines=[], removed_lines=[]):
    content = ""
    try:
        with open(path) as f:
            content = f.read().decode("utf8")
    except OSError as exc:
        if exc.errno != errno.EEXIST:
            raise

    modified = False
    lines = content.splitlines()
    for line in added_lines:
        if line not in lines:
            lines.append(line)
            log.notice("%s: patch: adding '%s'" % (task_name, line))
            modified = True
    removed_lines = set(removed_lines)
    for line in lines:
        if line in removed_lines:
            log.notice("%s: patch: removing '%s'" % (task_name, line))
            modified = True
    lines = [line for line in lines if line not in removed_lines]

    if not modified:
        log.notice("%s: already patched: %s" % (task_name, path))
        return

    new_content = "\n".join(lines)
    with open(path, "w") as f:
        f.write(new_content)

    log.success("%s: patched: %s" % (task_name, path))

def translate(task_name, tmpl_path, out_path, parser):
    eng = Engine()
    module = eng.load_file(tmpl_path, parser)
    path = module.path
    eng.make()
    outp = eng.modules[path].main({
        "banner": "This file was generated by dotfiler; do not edit"
    })
    with open(out_path, "w") as f:
        f.write(outp)
    log.success(task_name + ": generated: " + out_path)

mkdirp("global", "derived")

mkdirp("vim", path.join(home_dir, ".vim/bundle"))
git_clone("vim", path.join(home_dir, ".vim/bundle/Vundle.vim"), "https://github.com/VundleVim/Vundle.vim")
translate("vim", "vim/vimrc.tmpl", "derived/vimrc", Parser(sub_ch='%'))
per_line_patch("vim", path.join(home_dir, ".vimrc"),
    added_lines=["source %s/derived/vimrc" % base_path],
    removed_lines=["source ~/.dotfiles/vim/vimrc", "source %s/vim/vimrc" % base_path])

copy_no_overwrite("Default bash profile", "profile/default_bash_profile.sh", path.join(home_dir, ".bash_profile"))

translate("fishrc", "fish/config.tmpl.fish", "derived/config.fish", Parser(sub_ch='%'))
mkdirp("fishrc", path.join(home_dir, ".config/fish"))
per_line_patch("fishrc", path.join(home_dir, ".config/fish/config.fish"),
    added_lines=["source %s/derived/config.fish" % base_path],
    removed_lines=["source %s/fish/config.fish" % base_path, "source ~/.dotfiles/fish/config.fish"])

translate("bashrc", "bash/bashrc.tmpl.sh", "derived/bashrc.sh", Parser(sub_ch='%'))
per_line_patch("bashrc", path.join(home_dir, ".bashrc"),
    added_lines=[". %s/derived/bashrc.sh" % base_path],
    removed_lines=[". %s/bash/bashrc.sh" % base_path, ". ~/.dotfiles/bash/bashrc.sh"])

log.warn("patching .tmux.conf is not supported yet.")