#!/usr/bin/env python3

import os, sys, shutil, errno, glob
import os.path as path
from optparse import OptionParser
from texthon.parser import Parser
import dotfiler.logger as log
import dotfiler.paths as paths
from dotfiler.tasks import (mkdirp, git_clone, translate, per_line_patch,
    copy_no_overwrite, concatenate)

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

# Perform actions
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

mkdirp("ssh config", path.join(home_dir, ".ssh"))
concatenate("ssh config", path.join(home_dir, ".ssh/config"), [
    "local/ssh/config.d/*.conf",
    "private/ssh/config.d/*.conf",
    "ssh/config.d/*.conf"
])

translate("tmux", "tmux/tmux.tmpl.conf", "derived/tmux.conf", Parser(sub_ch='%'))
per_line_patch("tmux", path.join(home_dir, ".tmux.conf"),
    added_lines=['source "%s/derived/tmux.conf"' % base_path])

# Unison file synchronizer (https://github.com/bcpierce00/unison)
# TODO: delete old profiles
unison_profiles = [f
    for glb in ["local/unison/*.prf", "private/unison/*.prf", "unison/*.prf"]
    for f in glob.iglob(glb)]
mkdirp("unison", "derived/unison")
mkdirp("unison", paths.unison_data)
for name in unison_profiles:
    log.notice("unison: found %s" % name)
    if name.endswith('.tmpl.prf'):
        translated = "derived/unison/%s.prf" % path.basename(name)[:-9]
        translate("unison %s" % path.basename(name), name, translated, Parser(sub_ch='%'))
    else:
        translated = name

    concatenate(
        "unison %s" % path.basename(name),
        path.join(paths.unison_data, path.basename(translated)),
        [translated])
