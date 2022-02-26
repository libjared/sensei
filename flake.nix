{
  description = "Sensei";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };
  outputs = { self, nixpkgs, flake-utils }:
  (
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system: let
      overlays = [];
      pkgs = import nixpkgs {
        inherit system overlays;
        # config.allowBroken = true;
      };
      project = returnShellEnv: (
        pkgs.haskellPackages.developPackage {
          inherit returnShellEnv;
          name = "sensei";
          root = ./.;
          overrides = (hself: hsuper: {
            hspec = pkgs.haskell.lib.dontCheck hsuper.hspec_2_9_4;
            hspec-core = pkgs.haskell.lib.dontCheck hsuper.hspec-core_2_9_4;
            hspec-discover = pkgs.haskell.lib.dontCheck hsuper.hspec-discover_2_9_4;
          });
          modifier = drv: pkgs.haskell.lib.overrideCabal drv (old: {
            testHaskellDepends = old.testHaskellDepends ++ [ pkgs.haskellPackages.hspec-meta_2_9_3 ];
            testToolDepends = old.testToolDepends ++ [ pkgs.git ];
          });
        }
      );
      in {
        defaultPackage = project false;
        devShell = project true;
      }
    )
  );
}
