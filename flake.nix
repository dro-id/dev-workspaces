# Main Nix Flake to rule all dev workspaces

{

  description = "Marc's dev workspaces";

  inputs = {

    # Used by the core system config
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-24.05";
    };
    nixpkgs-unstable = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    # Community packages, mostly use for addons
    nur = {
      url = github:nix-community/NUR;
    };

    # Used by devenv for development environments
    devenv = {
      url = "github:cachix/devenv";
    };

    # Rust complete toolchain, rustup replacement
    fenix = {
      url = github:nix-community/fenix;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Overlays
    # No overlays for now

  };

  outputs = { self, flake-parts, nixpkgs, nixpkgs-unstable, nur, devenv, fenix, ... } @ inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {

      imports = [
        devenv.flakeModule
      ];
   
      systems = nixpkgs.lib.systems.flakeExposed;

      perSystem = { config, self', inputs', pkgs, system, ... }: {

      _module.args.pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      
        devenv.shells.nix               = { imports = [ ./devenv/nix/devenv.nix ]; };
        devenv.shells.rust-stable       = { imports = [ ./devenv/rs/devenv.nix ]; };
        devenv.shells.python-stable     = { imports = [ ./devenv/py/devenv.nix ]; };
        devenv.shells.javascript-stable = { imports = [ ./devenv/js/devenv.nix ]; };
        devenv.shells.terraform-stable  = { imports = [ ./devenv/tf/devenv.nix ]; };
        
        devShells.default = config.devShells.nix;
        
      };
      
    };
    
}
