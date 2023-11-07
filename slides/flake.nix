{
  description = "A basic flake with a shell";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        tex = pkgs.texlive.combine {
          inherit (pkgs.texlive) scheme-small;
          inherit (pkgs.texlive) latexmk pgf pgfplots tikzsymbols biblatex beamer;
          inherit (pkgs.texlive) silence appendixnumberbeamer fira fontaxes mwe;
          inherit (pkgs.texlive) noto csquotes babel helvetic transparent;
          inherit (pkgs.texlive) xpatch hyphenat wasysym algorithm2e listings;
          inherit (pkgs.texlive) lstbayes ulem subfigure ifoddpage relsize;
          inherit (pkgs.texlive) adjustbox media9 ocgx2 biblatex-apa wasy;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.bashInteractive
            pkgs.pdfpc
          ];
        };
        defaultPackage = pkgs.stdenvNoCC.mkDerivation rec {
          name = "slides";
          src = self;
          buildInputs = [
            pkgs.coreutils
            tex
            pkgs.gnuplot
            pkgs.biber
          ];
          phases = [ "unpackPhase" "buildPhase" "installPhase" ];
          buildPhase = ''
            export PATH="${pkgs.lib.makeBinPath buildInputs}";
            export HOME=$(pwd)
            latexmk -pdflatex -shell-escape slides.tex
          '';
          installPhase = ''
            mkdir -p $out
            cp slides.pdf $out/
          '';
        };
      });
}
