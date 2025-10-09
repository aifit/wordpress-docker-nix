{
  description = "WordPress + MariaDB dev environment (Docker + Colima for macOS)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      # Define supported systems
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      # Helper function to generate an attribute set for all systems
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in f pkgs system
      );
    in {
      # devShells output structure: devShells.<system>.<name>
      devShells = forAllSystems (pkgs: system: {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [
            docker
            docker-compose
          ] ++ pkgs.lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
            colima
          ];

          shellHook = ''
            echo "👉 WordPress + MariaDB dev shell ready"

            if [[ "$(uname)" == "Darwin" ]]; then
              echo "Detected macOS"
              echo "Start Colima with resources, e.g.:"
              echo "$ colima start --cpu 2 --memory 4 --disk 15"
              echo "Then run: docker-compose up -d"
            else
              echo "Detected Linux"
              echo "Make sure Docker daemon is running:"
              echo "$ sudo systemctl start docker"
              echo "Then run: docker-compose up -d"
            fi
          '';
        };
      });
    };
}
