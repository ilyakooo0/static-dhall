{
  description = "static-dhall: an opinionated static site generator using Dhall and Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system:
        f {
          pkgs = nixpkgs.legacyPackages.${system};
          inherit system;
        }
      );
    in
    {
      lib = forAllSystems ({ pkgs, ... }: {
        buildSite = import ./nix/buildSite.nix { inherit pkgs; };
      });

      packages = forAllSystems ({ pkgs, ... }: {
        example = import ./nix/buildSite.nix { inherit pkgs; } {
          src = ./templates/default;
        };
      });

      templates.default = {
        path = ./templates/default;
        description = "A basic static-dhall site";
      };
    };
}
