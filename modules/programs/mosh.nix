{ pkgs, lib, config, ... }:

with lib;

let
	cfg = config.programs.mosh;
in
{
	options.programs.mosh = {
		overrideByDotfiles = mkOption {
			default = true;
			type = types.bool;
		};
	};
	
	config = mkIf cfg.overrideByDotfiles {
		nixpkgs.overlays = [ (self: super: {
			mosh = pkgs.callPackage ../../pkgs/mosh {};
		} ) ];
	};
}

