yvt does dotfiles
=================

First, install [Nix](https://nixos.org/nix/) if not installed yet:

```shell
curl https://nixos.org/nix/install | sh
```

(See [this comment](https://github.com/NixOS/nix/issues/2925#issuecomment-539490866) for how to install Nix on macOS Catalina.)

Next, install [Home Manager](https://github.com/rycee/home-manager):

```shell
nix-channel --add https://github.com/rycee/home-manager/archive/master.tar.gz home-manager
nix-channel --update
```

And then do:

```shell
ln -s `pwd` ~/.config/nixpkgs
nix-shell '<home-manager>' -A install
```

Private directory
-----------------

You might not want to expose SSH config files or something like that into the public repository because doing so would put your precious servers at potential security risk. So `.dotfiles/private` is reserved for private information. Clone your own private dotfiles respository to `private`. ~~`private-example` shows an example.~~

Local directory
---------------

Place host-local configuration files in `local`.
