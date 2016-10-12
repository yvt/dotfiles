#import dotfiler.components as comps
#import dotfiler.paths as paths
#import dotfiler.logger as log
#import os.path as path
#import sys as sys
#load "../common/shellrc.tmpl" as shellrc
#load "./lib.tmpl.sh" as lib

#template main(options)
%{"# " + options['banner']}

#* Set locale
export LC_ALL="en_US.UTF-8"

add_path() {
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        PATH="${PATH:+"$PATH:"}$1"
    fi
}

#* Emit the shared part
%{shellrc.main(lib)}%>

#* Setup powerline
#!powerline_pkg = comps.get("PowerlineStatusPackage")
#!powerline_daemon = comps.get("PowerlineDaemon")
#{if powerline_pkg.exists and powerline_daemon.exists:
%{powerline_daemon.path} -q
POWERLINE_BASH_CONTINUATION=1
POWERLINE_BASH_SELECT=1
. %{lib.escape(path.join(powerline_pkg.bindings_path, "bash/powerline.sh"))}
#}

#* RVM
#!rvm = comps.get("RVM")
#{if rvm.exists:
. %{lib.escape(rvm.bash_profile)}
#}

#* Editor
alias edit=$EDITOR

#end template