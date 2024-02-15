{
  description = "Bayesian Statistics flake with a shell";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  inputs.treefmt-nix.url = "github:numtide/treefmt-nix";

  outputs = { self, nixpkgs, flake-utils, pre-commit-hooks, treefmt-nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;

        julia = pkgs.julia-bin.overrideDerivation (oldAttrs: { doInstallCheck = false; });

        typst-packages = builtins.fetchGit {
          url = "https://github.com/typst/packages.git";
          ref = "main";
          rev = "aa400735cba3e5bd312b14c69a7b56a01a1b35e4";
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

        checks = {
          formatting = treefmtEval.config.build.check self;
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              typos.enable = true;
              treefmt = {
                enable = true;
              };
              typst-fmt = {
                enable = true;
                name = "Typst Formatter";
                entry = "${pkgs.typstfmt}/bin/typstfmt";
                files = "\\.typ$";
                language = "rust";
              };
              julia-formatter = {
                enable = true;
                name = "format julia code";
                entry = ''
                  ${julia}/bin/julia -e '
                  using Pkg
                  Pkg.activate(".")
                  Pkg.add("JuliaFormatter")
                  using JuliaFormatter
                  format(ARGS)
                  out = Cmd(`git diff --name-only`) |> read |> String
                  if out == ""
                      exit(0)
                  else
                      @error "Some files have been formatted !!!"
                      write(stdout, out)
                      exit(1)
                  end'
                '';
                files = "\\.jl$";
                language = "system";
              };
            };
            settings = {
              treefmt.package = treefmtEval.config.build.wrapper;
            };
          };
        };

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
            ${self.checks.${system}.pre-commit-check.shellHook}
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
