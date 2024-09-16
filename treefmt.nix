{ pkgs, ... }:

{
  # Used to find the project root
  projectRootFile = "flake.nix";

  # Enable formatters
  programs.nixpkgs-fmt.enable = true;
  programs.prettier.enable = true;

  # Custom typstyle
  settings.formatter.typstyle = {
    command = "${pkgs.typstyle}/bin/typstyle";
    options = [
      "--check"
    ];
    includes = [ "*.typ" "*.typst" ];
  };
}
