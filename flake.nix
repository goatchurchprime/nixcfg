{
  description = "A NixOS flake for Julian Todd's machine(s).";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware/83009edccc2e24afe3d0165ed98b60ff7471a5f8";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixos-hardware, home-manager, ... }@inputs:
    let
      # Generate a user-friendly version numer.
      version = builtins.substring 0 8 self.lastModifiedDate;

      # System types to support.
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { config.allowUnfree = true; inherit system; overlays = [ self.overlay ]; });
    in
    {
      nixosConfigurations = rec {
        nixos = goatlap;
        goatlap = nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";
          modules = [
            nixos-hardware.nixosModules.common-pc-laptop-ssd
            nixos-hardware.nixosModules.common-cpu-intel
            (import ./hosts/goatlap/configuration.nix)
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.julian = import ./hosts/goatlap/home-manager.nix;
              nixpkgs.pkgs = nixpkgsFor.x86_64-linux;
            }
          ];
          specialArgs = {
            inherit inputs;
            pkgs = nixpkgsFor."${system}";
          };
        };
      };

      overlay = final: prev: {};
    };
}

