{
  description = "A simple CLI image ditherizer";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      name = "peony";
      allSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });
    in
    {
      packages = forAllSystems ({ pkgs }: {
        default = pkgs.stdenv.mkDerivation {
          inherit name;
          src = ./.;

          nativeBuildInputs = with pkgs; [
            gnumake
            pkg-config
          ];

          buildInputs = with pkgs; [
            clang-tools

            pkgs.llvmPackages_latest.libstdcxxClang
            pkgs.llvmPackages_latest.libcxx

            opencv2
          ];

          installPhase = ''
            mkdir -p $out/bin
            cp ${name} $out/bin
          '';
        };
      });
    };
}
