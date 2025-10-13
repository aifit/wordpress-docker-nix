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

            # Color aliases for commands
            alias ls='ls --color=auto'

            # Colored prompt: user@host:dir$
            export PS1="\[\e[33m\]\u@\h\[\e[32m\]:\$(basename \$PWD)\[\e[36m\] (nix)\[\e[0m\]\$ "

            echo ""
            echo " ❄️ WordPress + MariaDB dev shell ready"
            echo ""
            if [[ "$(uname)" == "Darwin" ]]; then
              echo -e " Detected system: \e[32mmacOS\e[0m"
              echo " Start Colima with resources, e.g.:"
              echo -e " $ \e[36mcolima start --cpu 2 --memory 4 --disk 15\e[0m"
              echo " Then run:"
              echo -e " $ \e[36mdocker-compose up -d\e[0m"
              echo ""
            else
              echo " Detected system: \e[32mLinux\e[0m"
              echo " Make sure Docker daemon is running:"
              echo -e " $\e[36mdocker --version\e[0m"
              echo " Then run:"
              echo -e " $ \e[36mdocker-compose up -d\e[0m"
            fi
            echo ""
            echo -e "Readme:"
            echo -e "   \e[34mhttps://github.com/aifit/wordpress-docker-nix/blob/main/README.md\e[0m"
            echo ""
          '';
        };
      });
    };
}
