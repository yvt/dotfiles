#import dotfiler.components as comps
#import dotfiler.paths as paths
#import os.path as path
#import sys as sys
#load "../common/shellrc.tmpl" as shellrc
#load "./lib.tmpl.fish" as lib

#template main(options)
%{"# " + options['banner']}

#* Set locale
set -x LC_ALL "en_US.UTF-8"

function add_path
  set ADDED_PATH $argv[1]
  not contains $ADDED_PATH $PATH
    and set -x PATH $ADDED_PATH $PATH
end

#* Emit the shared part
%{shellrc.main(lib)}%>

#* Setup powerline
#!powerline_pkg = comps.PowerlineStatusPackage.get()
#!powerline_daemon = comps.PowerlineDaemon.get()
#{if powerline_pkg.exists and powerline_daemon.exists:
%{powerline_daemon.path} -q
set fish_function_path $fish_function_path %{lib.escape(path.join(powerline_pkg.bindings_path, "fish"))}
powerline-setup
#}

#* Editor
function edit
  eval $EDITOR $argv
end

#end template