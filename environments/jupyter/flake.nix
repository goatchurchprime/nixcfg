{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }: 
    let
      # Generate a user-friendly version numer.
      version = builtins.substring 0 8 self.lastModifiedDate;

      # System types to support.
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ self.overlay ]; });

    in
    {
      overlay = final: prev: {
        python39Packages = final.python39.pkgs;
        python39 = prev.python39.override {
          packageOverrides = self: super: {
            jupyter_micropython_kernel = super.buildPythonPackage rec {
              pname = "jupyter_micropython_kernel";
              version = "0.1.3.2";
              src = super.fetchPypi {
                inherit pname version;
                sha256 = "sha256-YqW5rh4dgPKRWa9ZqwVTFEtzTNE2SxBLqmxjuLRd9XE=";
              };
              doCheck = false;
              buildInputs = [ self.websocket-client self.pyserial ];
            };
            geomdl = super.buildPythonPackage rec {
              pname = "geomdl";
              version = "5.3.1";
              src = super.fetchPypi {
                inherit pname version;
                sha256 = "sha256-6BoxtNXxESZ7FgRbodlTkjWpiyz/XkutGPfdzUy4BMg=";
              };
              doCheck = false;
            };
            ezdxf = super.buildPythonPackage rec {
              pname = "ezdxf";
              version = "0.17";
              src = super.pkgs.fetchFromGitHub {
                owner = "mozman";
                repo = "ezdxf";
                rev = "v${version}";
                sha256 = "sha256-O6/9fPu/xbjpv//qohqC15dp8lfWML9/+5sy6QgHoOk=";
              };
              doCheck = false;
              propagatedBuildInputs = [ self.pyparsing ];
              buildInputs = [ self.geomdl self.typing-extensions ];
            };
          };
        };
      };

      devShell = forAllSystems (system:
        let
          pkgs = nixpkgsFor."${system}";
        in
          pkgs.mkShell {
            buildInputs = with pkgs.python39Packages; [
              jupyter scipy matplotlib pandas matplotlib sympy ezdxf jupyter_micropython_kernel pyserial websocket_client pyproj
            ];
            shellHook = "python -m jupyter_micropython_kernel.install";
          }
      );

    };
  
}
