{
  description = "A NixOS flake for Julian Todd's machine(s).";

  inputs = {
    nixpkgs.url = "nixpkgs/f6551e1efa261568c82b76c3a582b2c2ceb1f53f";
    nixpkgsUnstable.url = "nixpkgs/nixos-unstable";
    godot-source = {
      url = "github:godotengine/godot/3.3.3-stable";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nixpkgsUnstable, godot-source, ... }@inputs: 
    let
      # Generate a user-friendly version numer.
      version = builtins.substring 0 8 self.lastModifiedDate;

      # System types to support.
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ self.overlay ]; });
      nixpkgsUnstableFor = forAllSystems (system: import nixpkgsUnstable { inherit system; overlays = [ self.overlay ]; });

    in
    {
      nixosConfigurations = rec {
        nixos = goatlap;
        goatlap = nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";
          modules = [
            (import ./hosts/goatlap/configuration.nix)
          ];
          specialArgs = {
            inherit inputs;
            pkgs = nixpkgsFor."${system}";
          };
        };
      };

      overlay = final: prev:
        let 
          inherit (final) stdenv lib fetchFromGitHub godot godot-headless godot-export-templates fetchurl runCommandNoCC unzip;
        in
        {
          my-godot = nixpkgsUnstableFor."${final.hostPlatform .system}".godot.overrideAttrs (oldAttrs: rec {
            version = godot-source.rev;
            src = godot-source;
          });
        };

    };
}

