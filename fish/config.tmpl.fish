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

function add_path_weak
  set ADDED_PATH $argv[1]
  not contains $ADDED_PATH $PATH
    and set -x PATH $PATH $ADDED_PATH
end

#* Fish-specific Nix profile initialization
#!singleuser_nix = comps.SingleUserNix.get()
#{if singleuser_nix.exists:
source %{paths.dotfiles}/fish/nix.fish
#}

#* Emit the shared part
%{shellrc.main(lib)}%>

#* Setup powerline
#!powerline_rs = comps.PowerlineRS.get()
#!powerline_pkg = comps.PowerlineStatusPackage.get()
#!powerline_daemon = comps.PowerlineDaemon.get()
#{if powerline_rs.exists:
function fish_prompt
  %{powerline_rs.path} --shell bare $status
end
#}
#{elif powerline_pkg.exists and powerline_daemon.exists:
%{powerline_daemon.path} -q
set fish_function_path $fish_function_path %{lib.escape(path.join(powerline_pkg.bindings_path, "fish"))}
powerline-setup
#}

#* Setup pipenv
#!pipenv = comps.Pipenv.get()
#{if pipenv.exists:
eval (env _PIPENV_COMPLETE=source-fish %{lib.escape(pipenv.path)})
#}

#* Setup OPAM
#!opam = comps.OPAM.get()
#{if opam.exists:
eval (%{lib.escape(opam.path)} config env)
#}

#* Editor
function edit
  eval $EDITOR $argv
end

#* fish-specific aliases
abbr -- -t 'tmux attach; or tmux new'

#end template
