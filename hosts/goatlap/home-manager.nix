{ config, lib, pkgs, modulesPath, ... }:

{
  programs.vscode = {
    enable = true;
    #package = pkgs.vscodium;
    extensions = with pkgs.vscode-extensions; [
      serayuzgur.crates
      tamasfe.even-better-toml
      bbenoist.nix
      #jock.svg
      editorconfig.editorconfig
      coenraads.bracket-pair-colorizer-2
      esbenp.prettier-vscode
      emmanuelbeziat.vscode-great-icons
      davidanson.vscode-markdownlint
      timonwong.shellcheck

      eamodio.gitlens
      ms-vscode.cpptools
    ];
  };
}
