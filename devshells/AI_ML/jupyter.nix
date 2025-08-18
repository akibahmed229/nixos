{
  description = "Flake: reproducible devshell for Data Science / ML / DS / AI";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; # pin to a channel/ref you trust
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          config = {allowUnfree = true;};
        };

        # Choose the Python interpreter you want here:
        python = pkgs.python313;

        # Create a single nix-managed Python environment containing the packages
        pyEnv = python.withPackages (ps:
          with ps; [
            # basics
            pip
            ipykernel
            jupyterlab
            pyzmq

            # data science
            numpy
            pandas
            matplotlib
            seaborn
            scikit-learn
            plotly
            openpyxl

            # networking / utils
            requests

            # add more as needed (tensorflow, torch, xgboost, etc.) — see notes below
          ]);

        # Core system libs you want available (avoid bloating; add only needed libs)
        systemLibs = with pkgs; [git openssl libxml2 libxslt zlib];
      in {
        # Default devShell (minimal and reproducible)
        devShells.${system}.default = pkgs.mkShell {
          name = "ds-devshell-${system}";

          # Put the single python env into the environment (preferred approach)
          buildInputs = systemLibs ++ [pyEnv];

          # Minimal environment variables
          shellHook = ''
            echo "\nEntering nix-managed DataScience devshell (${system})"

            # Optional: register a Jupyter kernel that uses the nix-managed python
            if ! jupyter kernelspec list 2>/dev/null | grep -q ds-devshell || true; then
              echo "Registering 'ds-devshell' kernel for Jupyter (user scope)"
              python -m ipykernel install --user --name ds-devshell --display-name "DS (nix)"
            fi

            # Optional helper for VSCode: symlink a `.venv` to the nix python prefix so the extension can detect it
            # Only create the link if it doesn't already exist
            if [ ! -e .venv ]; then
              venv_dir="$(cd $(dirname $(which python)); cd ..; pwd)" || true
              ln -sfn "$venv_dir" .venv
            fi
          '';

          # tidy prompt to show we are inside nix devshell
          PS1 = "[ds-devshell] ${pkgs.lib.getEnv "PS1"}";
        };

        # A heavier devShell with optional ML/AI packages (e.g. TensorFlow, PyTorch)
        devShells.${system}.AL_ML_DS_AI = pkgs.mkShell {
          name = "ds-ml-devshell-${system}";

          # Use the same python and add heavier libs via another python.withPackages or additional buildInputs
          pyEnvML = python.withPackages (ps:
            with ps; [
              pip
              ipykernel
              jupyterlab
              numpy
              pandas
              matplotlib
              seaborn
              scikit-learn
              plotly
              openpyxl
              requests

              # NOTE: For GPU-enabled PyTorch/TensorFlow you will likely need to install
              # from upstream wheels or use dedicated nixpkgs packages (search in nixpkgs).
              # Examples (may not exist in your channel): tensorflow
              # torch
            ]);

          buildInputs = systemLibs ++ [pyEnvML];

          shellHook = ''
            echo "\nEntering ML/AI devshell (heavier)"
            if ! jupyter kernelspec list 2>/dev/null | grep -q ds-ml || true; then
              python -m ipykernel install --user --name ds-ml --display-name "DS-ML (nix)"
            fi
            if [ ! -e .venv ]; then
              venv_dir="$(cd $(dirname $(which python)); cd ..; pwd)" || true
              ln -sfn "$venv_dir" .venv
            fi
          '';
        };
      }
    );
}
