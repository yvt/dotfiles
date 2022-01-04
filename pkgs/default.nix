{ pkgs, ... }:
with pkgs;

rec {
  dfu-util-gd32 = callPackage ./dfu-util/gd32.nix;
  dfu-util-git = callPackage ./dfu-util/git.nix;

  # <https://github.com/NixOS/nixpkgs/tree/84cf00f98031e93f389f1eb93c4a7374a33cc0a9>
  qemu_4_2 = callPackage ./qemu-4.2 {
    inherit (darwin.apple_sdk.frameworks) CoreServices Cocoa Hypervisor;
    inherit (darwin.stubs) rez setfile;
    python = python3;
  };

  qemu_4_2_riscv32 = qemu_4_2.override { hostCpuTargets = ["riscv32-softmmu"]; };
  qemu_4_2_riscv64 = qemu_4_2.override { hostCpuTargets = ["riscv64-softmmu"]; };

  xnethack = callPackage ./xnethack;

  gtkterm = callPackage ./gtkterm;
}
