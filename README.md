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
* **tmux**
  * enables [Powerline](https://github.com/powerline/powerline) status line
* **vim**
  * disables the compatible mode
  * installs [Vundle](https://github.com/VundleVim/Vundle.vim) and some plugins
    * `vim-sleuth`
    * `vim-airline`: more lightweight than using powerline

Featuring a few programs...
--------------------------

- `dotfiles-bootstrap.sh` updates config files automatically.
  - Note that this script doesn't install the required programs.
  - Cannot update some files yet.
- `update-ssh-config.sh`: `.ssh/config` doesn't support inclusion of files. This is where `update-ssh-config.sh` comes in! It merges all config files in `(private/)?ssh/config.d` and creates `.ssh/config` file.
- `random-hex` generates a random string suitable fo use as a password.
  Don't forget to make sure no one except you are watching the terminal, and to clear the terminal after using this!


Private directory
-----------------

You might not want to expose SSH config files or something like that into the public repository because doing so would result in a potential security risk. So `.dotfiles/private` is reserved for private information. Clone your own private dotfiles respository to `private`. `private-example` shows an example.


Notes
-----

This dotfiles uses [Powerline](https://github.com/powerline/powerline) for fancy
prompt so you need to use the [patched fonts](https://github.com/powerline/fonts). 
