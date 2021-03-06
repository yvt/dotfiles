yvt does dotfiles
=================

* **bash**
  * the same as fish but doesn't define an alias for fancy `ls`
  * doesn't define commands
* **fish**
  * changes the locale to `en_US.UTF-8`
  * update the `TERM` variable to `screen-256color` if it was `screen`
  * enables [Powerline](https://github.com/powerline/powerline) prompt
  * enables [RVM](https://rvm.io/) (todo!)
  * sets the default editor to Vim
  * defines some commands including:
  	* `edit`: edit a file using the default editor (`EDITOR`)
    * `e`: abbreviation for `edit`
    * `g-s`: `git status`
    * `g-c`: `git commit`
    * `-t`: `tmux attach || tmux new`
    * `-jc`: `journalctl`, `-sc`: 'systemctl'
    * `sc-[tprs]`: `systemctl (start|stop|restart|status)`, respectively
    * `jc-x`: `journalctl -xe`
* **ssh**
  * Better configuration management by `update-ssh-config.sh`
* **tmux**
  * enables [Powerline](https://github.com/powerline/powerline) status line
* **vim**
  * disables the compatible mode
  * installs [Vundle](https://github.com/VundleVim/Vundle.vim) and some plugins
    * `vim-sleuth`
    * `vim-airline`: more lightweight than using powerline

Featuring a few programs...
--------------------------

- `dotfiles-bootstrap.py` updates config files automatically.
  - Note that this script doesn't install the required programs.
  - `.ssh/config` doesn't support inclusion of files. This is also where `dotfiles-bootstrap.py` comes in! It merges all config files in `(private/|local/)?ssh/config.d` and creates `.ssh/config` file.
- `random-hex` generates a random string suitable fo use as a password.
  Don't forget to make sure no one except you are watching the terminal, and to clear the terminal after using this!


Private directory
-----------------

You might not want to expose SSH config files or something like that into the public repository because doing so would put your precious servers at potential security risk. So `.dotfiles/private` is reserved for private information. Clone your own private dotfiles respository to `private`. `private-example` shows an example.

Local directory
---------------

Place host-local scripts in `local/bin`.

Notes
-----

This dotfiles uses [Powerline](https://github.com/powerline/powerline) for fancy
prompt so you need to use the [patched fonts](https://github.com/powerline/fonts). 
