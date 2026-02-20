{ pkgs }:

{ src
, layoutsDir ? ../dhall/layouts
, themeDir ? ../theme
, dhallPackage ? ../dhall/package.dhall
}:

pkgs.stdenv.mkDerivation {
  name = "static-dhall-site";

  inherit src;

  nativeBuildInputs = with pkgs; [
    dhall
    dhall-json
    pandoc
    jq
  ];

  buildPhase = ''
    export HOME=$(mktemp -d)

    # Copy source to a writable directory and add .static-dhall symlink
    workdir=$(mktemp -d)
    cp -r $src/* "$workdir/"
    ln -s ${../dhall} "$workdir/.static-dhall"

    export layoutsDir=${layoutsDir}
    export themeDir=${themeDir}
    export src="$workdir"
    bash ${../nix/builder.sh}
  '';

  dontInstall = true;
}
