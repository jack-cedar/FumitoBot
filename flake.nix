{
  description = "Basic flake for dotnet";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nuget-packageslock2nix = {
      url = "github:mdarocha/nuget-packageslock2nix/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  outputs = { self,
              nixpkgs,
              flake-utils,
              nuget-packageslock2nix }: flake-utils.lib.eachDefaultSystem
                (system: let
                  
                  pkgs = nixpkgs.legacyPackages.${system};
         
                  project = with pkgs; buildDotnetModule rec {
                    pname = "fumitoBot";
                    version = "0.1";
                    src = ./.;
                    projectFile = "${pname}.fsproj";
                    packNupkg = true;

                    nugetDeps = nuget-packageslock2nix.lib {
                      system = system;
                      lockfiles = [./packages.lock.json];
                    };};
                in
                  {
                    packages.${project.pname} = project;
                    
                    defaultPackage = self.packages.${system}.${project.pname};
                    
                    devShell = with pkgs; mkShell { buildInputs = [ dotnet-sdk ];
                                                    shellHook = "dotnet restore";
                                                  };
                    
                    inputsFrom = builtins.attrValues self.packages.${system};
                  });}
