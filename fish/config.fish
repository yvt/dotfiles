set -x DOTFILES ~/.dotfiles

# system check
function system_check_fail
  test $CHECK_SYSTEM = "YES"
    and echo $argv
end

# Set locale
set -x LC_ALL "en_US.UTF-8"

# Setup path
function add_path
  set ADDED_PATH $argv[1]
  test -e $ADDED_PATH
    and not contains $ADDED_PATH $PATH
    and set -x PATH $ADDED_PATH $PATH
end

add_path /usr/local/bin
add_path /usr/local/sbin
add_path /opt/local/bin
add_path /opt/local/sbin
add_path /opt/local/Library/Frameworks/Python.framework/Versions/2.7/bin
add_path /opt/local/Library/Frameworks/Python.framework/Versions/3.4/bin
add_path /Library/Frameworks/Python.framework/Versions/3.4/bin
add_path ~/.rakudobrew/bin
add_path ~/usr/bin
add_path $DOTFILES/bin
add_path $DOTFILES/private/bin

# Fix TERM variable
test $TERM = screen
  and begin
    test -f /usr/share/terminfo/s/screen-256color
    or test -f /lib/terminfo/s/screen-256color
    or test -f /usr/share/terminfo/73/screen-256color
  end
  and set -x TERM screen-256color

# Setup powerline
which powerline-daemon > /dev/null; and begin
  powerline-daemon -q
  
  # locate the powerline
  set -l POWERLINE_DIRS "/usr/local/lib/python3.4/dist-packages/powerline"
  set -l POWERLINE_DIRS $POWERLINE_DIRS "/Library/Frameworks/Python.framework/Versions/3.4/lib/python3.4/site-packages/powerline"
  set -l POWERLINE_DIRS $POWERLINE_DIRS "/Library/Python/2.7/site-packages/powerline"
  set -l POWERLINE_DIRS $POWERLINE_DIRS "/usr/lib/python3.4/site-packages/powerline"
  set -l POWERLINE_DIRS $POWERLINE_DIRS "/usr/lib/python2.7/site-packages/powerline"
  set -l POWERLINE_DIRS $POWERLINE_DIRS "/opt/local/Library/Frameworks/Python.framework/Versions/3.4/lib/python3.4/site-packages/powerline"
  set -l POWERLINE_DIRS $POWERLINE_DIRS "/opt/local/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/site-packages/powerline"
  set -l POWERLINE_DIRS $POWERLINE_DIRS "/usr/share/powerline"
  set -l POWERLINE_FOUND ""

  for POWERLINE_DIR in $POWERLINE_DIRS
    test -e $POWERLINE_DIR/bindings/fish/powerline-setup.fish
      and begin
        set POWERLINE_FOUND $POWERLINE_DIR/bindings/fish
        break
      end
    test -e $POWERLINE_DIR/fish/powerline-setup.fish
      and begin
        set POWERLINE_FOUND $POWERLINE_DIR/fish
        break
      end
  end

  test $POWERLINE_FOUND != ""; and begin
    set fish_function_path $fish_function_path $POWERLINE_FOUND
    powerline-setup
  end
end; or system_check_fail "powerline not found."

# TODO: RVM

# Man's best friend
not contains $EDITOR vim subl
  and set -x EDITOR vim

# Abbreviations
function edit
  eval $EDITOR $argv
end
abbr e edit
abbr g-s git status
abbr g-c git commit



