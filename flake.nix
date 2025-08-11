{
  description = "Bayesian Statistics flake with a shell";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.treefmt-nix.url = "github:numtide/treefmt-nix";

  outputs = { self, nixpkgs, flake-utils, treefmt-nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;

        julia = pkgs.julia-bin.overrideDerivation (oldAttrs: { doInstallCheck = false; });

        typst-packages = builtins.fetchGit {
          url = "https://github.com/typst/packages.git";
          ref = "main";
          rev = "66f5634493fe02d406b5e43d674696669fb77442"; # 2025-08-11
        };

        typst-fonts = pkgs.stdenvNoCC.mkDerivation {
          name = "typst-fonts";

          src = self;

          installPhase =
            let
              fonts = {
                inherit (pkgs) fira fira-mono julia-mono inriafonts;
              };
            in
            pkgs.lib.concatStringsSep "\n" (map
              (name: ''
                mkdir -p $out/share/fonts/${name}
                cp -r ${fonts.${name}}/share/fonts/* $out/share/fonts/${name}
              '')
              (builtins.attrNames fonts));
        };
      in
      rec {
        formatter = treefmtEval.config.build.wrapper;

        checks.formatting = treefmtEval.config.build.check self;

        devShells.default = pkgs.mkShell {
          packages = with pkgs;[
            bashInteractive
            # pdfpc # FIXME: broken on darwin
            typos
            cmdstan
            julia

            # typst part
            typst
            typst-fonts
            typst-live
            typstfmt
            hayagriva
          ];

          shellHook = ''
            export JULIA_NUM_THREADS="auto"
            export JULIA_PROJECT="turing"
            export CMDSTAN_HOME="${pkgs.cmdstan}/opt/cmdstan"
            export TYPST_FONT_PATHS="${typst-fonts}/share/fonts"
          '';
        };
        packages = {
          inherit typst-fonts;
          default = pkgs.stdenvNoCC.mkDerivation {
            name = "slides";

            src = self;

            buildInputs = with pkgs; [
              typst
              typst-fonts
            ];

            buildPhase = ''
              mkdir -pv $out/.cache/typst
              cp -rv ${typst-packages}/packages $out/.cache/typst
              export XDG_CACHE_HOME="$out/.cache"
              export TYPST_FONT_PATHS="${typst-fonts}/share/fonts"
              typst compile ./slides/slides.typ ./slides/slides.pdf
            '';

            installPhase = ''
              cp ./slides/slides.pdf $out/
            '';
          };
        };
      });
}
