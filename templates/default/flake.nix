{
  description = "My static-dhall site";

  inputs = {
    static-dhall.url = "github:ilyakooo0/static-dhall";
  };

  outputs = { self, static-dhall }:
    let
      system = "x86_64-linux";
    in
    {
      packages.${system}.default = static-dhall.lib.${system}.buildSite {
        src = ./.;
      };
    };
}
