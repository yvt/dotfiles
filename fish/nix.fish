# `~/.nix-profile/etc/profile.d/nix.sh` ported to fish

if [ -n "$HOME" ] && [ -n "$USER" ]

    # Set up the per-user profile.
    # This part should be kept in sync with nixpkgs:nixos/modules/programs/shell.nix

    set NIX_LINK $HOME/.nix-profile
    set NIX_USER_PROFILE_DIR /nix/var/nix/profiles/per-user/$USER

    # macOS Catalina does not allow arbitrary root entries
    set -x NIX_IGNORE_SYMLINK_STORE 1

    # Append ~/.nix-defexpr/channels to $NIX_PATH so that <nixpkgs>
    # paths work when the user has fetched the Nixpkgs channel.
    set -x NIX_PATH (echo $NIX_PATH:)nixpkgs=$HOME/.nix-defexpr/channels/nixpkgs

    # Set up environment.
    # This part should be kept in sync with nixpkgs:nixos/modules/programs/environment.nix
    set -x NIX_PROFILES "/nix/var/nix/profiles/default $HOME/.nix-profile"

    # Set $NIX_SSL_CERT_FILE so that Nixpkgs applications like curl work.
    if [ -e /etc/ssl/certs/ca-certificates.crt ] # NixOS, Ubuntu, Debian, Gentoo, Arch
        set -x NIX_SSL_CERT_FILE /etc/ssl/certs/ca-certificates.crt
    else if [ -e /etc/ssl/ca-bundle.pem ] # openSUSE Tumbleweed
        set -x NIX_SSL_CERT_FILE /etc/ssl/ca-bundle.pem
    else if [ -e /etc/ssl/certs/ca-bundle.crt ] # Old NixOS
        set -x NIX_SSL_CERT_FILE /etc/ssl/certs/ca-bundle.crt
    else if [ -e /etc/pki/tls/certs/ca-bundle.crt ] # Fedora, CentOS
        set -x NIX_SSL_CERT_FILE /etc/pki/tls/certs/ca-bundle.crt
    else if [ -e "$NIX_LINK/etc/ssl/certs/ca-bundle.crt" ] # fall back to cacert in Nix profile
        set -x NIX_SSL_CERT_FILE "$NIX_LINK/etc/ssl/certs/ca-bundle.crt"
    else if [ -e "$NIX_LINK/etc/ca-bundle.crt" ] # old cacert in Nix profile
        set -x NIX_SSL_CERT_FILE "$NIX_LINK/etc/ca-bundle.crt"
    end

    set -x MANPATH "$NIX_LINK/share/man:$MANPATH"

    set -x PATH "$NIX_LINK/bin:$PATH"
    set -e NIX_LINK
    set -e NIX_USER_PROFILE_DIR
end

