{
  description = "Benjamin Rabier's Helix";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    helix.url = "github:helix-editor/helix";
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    helix,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        # enable all packages
        config = {allowUnfree = true;};
      };
      extraPackages = with pkgs; [
        rnix-lsp
        rust-analyzer-unwrapped
        terraform-ls
        nodePackages.pyright
        nodePackages."typescript-language-server"
        sumneko-lua-language-server
      ];
      helixPkg = helix.packages.${system}.default;
    in rec {
      apps.default = flake-utils.lib.mkApp {
        drv = packages.default;
        exePath = "/bin/hx";
      };
      packages.default = helixPkg.override {
        makeWrapperArgs = [
          ''--prefix PATH : "${pkgs.lib.makeBinPath extraPackages}"''
        ];
      };
    });
}
