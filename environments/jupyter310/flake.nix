{
  description = "Julians Jupyter notebook environment";
  
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
        python310Packages = final.python310.pkgs;
        python310 = prev.python310.override {
          packageOverrides = self: super: {
            laszip = super.buildPythonPackage rec {
              pname = "laszip-python";
              version = "0.2.1";
              src = super.pkgs.fetchFromGitHub {
                owner = "tmontaigu";
                repo = pname;
                rev = "v${version}";
                sha256 = "sha256-ujKoUm2Btu25T7ZrSGqjRc3NR1qqsQU8OwHQDSx8grY=";
              };
              doCheck = false;
              propagatedBuildInputs = [ self.pyparsing ];
              buildInputs = [ self.pybind11 super.pkgs.LASzip ];
             preBuild = ''
    cd ..
'';
            };
            laspy = super.buildPythonPackage rec {
              pname = "laspy";
              version = "2.3.0";
              src = super.pkgs.fetchFromGitHub {
                owner = "tmontaigu";
                repo = pname;
                rev = "v${version}";
                sha256 = "sha256-Wdbp6kjuZkJh+pp9OVczdsRNgn41/Tdt7nGFvewcQ1w";
              };
              doCheck = false;
              propagatedBuildInputs = [ self.numpy self.laszip ];
            };
          };
        };
      };

      devShell = forAllSystems (system:
        let
          pkgs = nixpkgsFor."${system}";
        in
          pkgs.mkShell {
            buildInputs = with pkgs.python310Packages; [
              jupyter svglib ezdxf
              scipy matplotlib pandas matplotlib sympy 
              pyserial laspy
              websocket_client pyproj ipympl ipywidgets seaborn influxdb
            ];
          }
      );

    };
  
}
