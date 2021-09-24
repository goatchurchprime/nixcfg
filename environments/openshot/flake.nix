{
  description = "Openshot with Libopenshot at 0.2.7";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    libopenshot-source = {
      url = "github:openshot/libopenshot/v0.2.7";
      flake = false;
    };
    libopenshot-audio-source = {
      url = "github:openshot/libopenshot-audio/v0.2.2";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, libopenshot-source, libopenshot-audio-source }:
    let
      # Generate a user-friendly version numer.
      version = builtins.substring 0 8 self.lastModifiedDate;

      # System types to support.
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = f:
        nixpkgs.lib.genAttrs supportedSystems (system: f system);

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system:
        import nixpkgs {
          inherit system;
          overlays = [ self.overlay ];
        });

    in {
      overlay = final: prev: {
        libsForQt5 = prev.libsForQt5.overrideScope' (self: super: {
          libopenshot = super.libopenshot.overrideAttrs (old: {
            src = libopenshot-source;
            buildInputs = old.buildInputs ++ [ prev.alsa-lib ];
            patches = [];
            postPatch = ''
              sed -i 's/{UNITTEST++_INCLUDE_DIR}/ENV{UNITTEST++_INCLUDE_DIR}/g' tests/CMakeLists.txt
              export _REL_PYTHON_MODULE_PATH=$(toPythonPath $out)
            '';
            OpenShotAudio_DIR = self.libopenshot-audio;
          });
          libopenshot-audio = super.libopenshot-audio.overrideAttrs (old: {
            src = libopenshot-audio-source;
            patches = [];
          });
        });
      };

      devShell = forAllSystems (system:
        let pkgs = nixpkgsFor."${system}";
        in pkgs.mkShell { buildInputs = with pkgs; [ openshot-qt ]; });
    };

}
