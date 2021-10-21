{ config, pkgs, lib, inputs, ...}:
{
  nix = {
    extraOptions =
      let empty_registry = builtins.toFile "empty-flake-registry.json" ''{"flakes":[],"version":2}''; in
      ''
        experimental-features = nix-command flakes
        flake-registry = ${empty_registry}
      '';
    registry.nixpkgs.flake = inputs.nixpkgs;
  };
}
