{
  description = "A simple CLI image ditherizer";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      allSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
        name = "peony_${system}";
      });
    in
    {
      packages = forAllSystems ({ pkgs, name }: {
        default = pkgs.stdenv.mkDerivation {
          name = name;
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

          buildPhase = ''
            TARGET=${name} make
          '';

          installPhase = ''
            mkdir -p $out/bin
            cp ${name} $out/bin
          '';
        };
      });
    };
}
