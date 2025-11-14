# Main Nix Flake to rule all dev workspaces

{

  description = "Marc's dev workspaces";

  inputs = {

    # Used by the core system config
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-25.05";
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
    # Foundry for Solidity development
    foundry = {
      url = github:shazow/foundry.nix;
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, flake-parts, nixpkgs, nixpkgs-unstable, nur, devenv, fenix, foundry, ... } @ inputs:
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
      
        devenv.shells.nix                       = { imports = [ ./devenv/nix/devenv.nix ]; };
        devenv.shells.rust-stable               = { imports = [ ./devenv/rs/devenv.nix ]; };
        devenv.shells.solidity-foundry-stable   = { imports = [ ./devenv/sol-f/devenv.nix ]; };
        devenv.shells.python-uv-stable          = { imports = [ ./devenv/py-uv/devenv.nix ]; };
        devenv.shells.javascript-npm-stable     = { imports = [ ./devenv/js-npm/devenv.nix ]; };
        devenv.shells.javascript-bun-stable     = { imports = [ ./devenv/js-bun/devenv.nix ]; };
        devenv.shells.terraform-stable          = { imports = [ ./devenv/tf/devenv.nix ]; };
        devenv.shells.cdktf-stable              = { imports = [ ./devenv/cdktf/devenv.nix ]; };
        
        devShells.default = config.devShells.nix;
        
      };
      
    };
    
}
