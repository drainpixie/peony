{
  description = "A simple CLI image ditherizer";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils, ... }@inputs:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        llvm = pkgs.llvmPackages_latest;
      in
      {
        devShell = pkgs.mkShell.override { stdenv = pkgs.clangStdenv; } rec {
          packages = with pkgs; [
            gnumake
            clang-tools

            llvm.libstdcxxClang
            llvm.libcxx

						opencv2
          ];
        };
      }
    );
}
