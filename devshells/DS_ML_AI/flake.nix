{
  description = "A reproducible devshell for Data Science and ML/AI";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    akibLib = {
      url = "github:akibahmed229/nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    akibLib,
    ...
  }:
    akibLib.lib.forAllSystems (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            # Configure CUDA support for the 'gpu' shell
            cudaSupport = true;
          };
        };

        # Choose your Python version
        python = pkgs.python312;

        # -- Define package sets to avoid repetition --

        # Common packages for all data science tasks
        commonPythonPackages = ps:
          with ps; [
            # Basics for interactivity
            pip
            ipykernel
            jupyterlab

            # Core data science stack
            numpy
            pandas
            matplotlib
            seaborn
            scikit-learn
            plotly
            openpyxl # For pandas Excel support
            requests
          ];

        # Heavy ML/AI packages for the GPU-enabled shell
        mlPythonPackages = ps:
          with ps; [
            # Use CUDA-enabled PyTorch from nixpkgs for best integration
            pytorchWithCuda
            # Standard CPU-based TensorFlow (see notes for GPU version)
            tensorflow
            # Other popular ML libraries
            xgboost
            catboost
          ];

        # Create the Python environments from the package sets
        pyEnv = python.withPackages commonPythonPackages;
        pyEnvGpu = python.withPackages (ps: (commonPythonPackages ps) ++ (mlPythonPackages ps));

        # Common system libraries
        systemLibs = with pkgs; [git openssl];

        # NVIDIA/CUDA libraries needed for the GPU shell
        cudaLibs = with pkgs; [
          cudatoolkit # Provides CUDA runtime libraries
        ];
      in {
        # -- Define the Development Shells --

        ## Default shell for general Data Science (CPU only)
        # To use: `nix develop`
        devShells.${system}.default = pkgs.mkShell {
          name = "ds-shell-${system}";
          packages = systemLibs ++ [pyEnv];

          shellHook = ''
            echo -e "\n✅ Entering Data Science devshell (CPU)\n"
            export PS1="[ds-shell] > "

            # Optional: Register a Jupyter kernel for this environment
            if ! jupyter kernelspec list 2>/dev/null | grep -q ds-cpu || true; then
              echo "Registering 'ds-cpu' kernel for Jupyter..."
              python -m ipykernel install --user --name ds-cpu --display-name "DS (Nix CPU)"
            fi

            # Optional: Symlink a .venv for VSCode Python extension
            if [ ! -e .venv ]; then
              ln -s "$(dirname $(which python))/.." .venv
              echo "Created .venv symlink for VSCode."
            fi
          '';
        };

        ## GPU-enabled shell for ML/AI
        # To use: `nix develop .#gpu`
        devShells.${system}.gpu = pkgs.mkShell {
          name = "ml-gpu-shell-${system}";
          packages = systemLibs ++ cudaLibs ++ [pyEnvGpu];

          # Environment variables required for CUDA libraries to be found
          shellHook = ''
            echo -e "\n🚀 Entering ML/AI devshell (GPU Enabled)\n"
            export PS1="[ml-gpu-shell] > "

            # Add CUDA binaries to the path
            export PATH="${pkgs.cudatoolkit}/bin:$PATH"

            # Point to CUDA libraries for PyTorch/TensorFlow
            export LD_LIBRARY_PATH="${pkgs.cudatoolkit.lib}/lib:$LD_LIBRARY_PATH"

            # Flags to improve performance with JAX/TensorFlow on GPU
            export XLA_FLAGS="--xla_gpu_cuda_data_dir=${pkgs.cudatoolkit}"

            # Optional: Register a Jupyter kernel for this environment
            if ! jupyter kernelspec list 2>/dev/null | grep -q ds-gpu || true; then
              echo "Registering 'ds-gpu' kernel for Jupyter..."
              python -m ipykernel install --user --name ds-gpu --display-name "DS (Nix GPU)"
            fi

            # Optional: Symlink a .venv for VSCode Python extension
            if [ ! -e .venv ]; then
              ln -s "$(dirname $(which python))/.." .venv
              echo "Created .venv symlink for VSCode."
            fi
          '';
        };
      }
    );
}
