{
  description = "osgrep — semantic code search for your AI agent";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        nodejs = pkgs.nodejs_20;
      in {
        packages.default = pkgs.stdenvNoCC.mkDerivation {
          pname = "osgrep";
          version = "0.5.16";
          src = self;

          nativeBuildInputs = [
            nodejs
            pkgs.pnpm.configHook
            pkgs.makeWrapper
          ];

          pnpmDeps = pkgs.fetchPnpmDeps {
            pname = "osgrep";
            version = "0.5.16";
            src = self;
            fetcherVersion = 3;
            hash = "sha256-LYOP+0ucui0Yck1si3TLuwqXYMB8mX7Mqa3CAOYw+zE=";
          };

          buildPhase = ''
            runHook preBuild
            pnpm build
            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall

            mkdir -p $out/lib/osgrep $out/bin
            cp -r dist node_modules package.json $out/lib/osgrep/

            makeWrapper ${nodejs}/bin/node $out/bin/osgrep \
              --add-flags "$out/lib/osgrep/dist/index.js" \
              --set NODE_PATH "$out/lib/osgrep/node_modules"

            runHook postInstall
          '';

          meta = with pkgs.lib; {
            description = "Semantic code search for your AI agent";
            homepage = "https://github.com/Ryandonofrio3/osgrep";
            license = licenses.asl20;
            mainProgram = "osgrep";
          };
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [ nodejs pkgs.pnpm ];
        };
      }
    );
}
