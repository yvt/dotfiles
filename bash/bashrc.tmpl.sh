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

add_path() { # FIXME: confirm this
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        PATH="${PATH:+"$PATH:"}$1"
    fi
}

add_path_weak() { # FIXME: confirm this
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        PATH="${PATH:+"$PATH:"}$1"
    fi
}

#* Emit the shared part
%{shellrc.main(lib)}%>

#* Setup powerline
#!powerline_rs = comps.PowerlineRS.get()
#!powerline_pkg = comps.PowerlineStatusPackage.get()
#!powerline_daemon = comps.PowerlineDaemon.get()
#{if powerline_rs.exists:
prompt() {
    PS1="$(%{powerline_rs.path} --shell bash $?)"
}
PROMPT_COMMAND=prompt
#}
#{elif powerline_pkg.exists and powerline_daemon.exists:
%{powerline_daemon.path} -q
POWERLINE_BASH_CONTINUATION=1
POWERLINE_BASH_SELECT=1
. %{lib.escape(path.join(powerline_pkg.bindings_path, "bash/powerline.sh"))}
#}

#* TODO: pipenv

#* RVM
#!rvm = comps.RVM.get()
#{if rvm.exists:
. %{lib.escape(rvm.bash_profile)}
#}

#* TODO: OPAM

#* Editor
alias edit=$EDITOR

#* bash-specific aliases
alias -- -t='tmux attach || tmux new'

#end template
