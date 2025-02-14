{
  pkgs ? import <nixpkgs> {},
  system,
  unstable,
  inputs,
}:
pkgs.mkShell {
  name = "DataScience-dev-environment";

  packages = [
    (pkgs.python313.withPackages (p:
      with p; [
        virtualenv
        pip
        ipykernel
        jupyterlab
        pyzmq
        venvShellHook
        pip
        numpy
        pandas
        # pandas-datareader
        matplotlib
        requests
        seaborn
        openpyxl
        # cufflinks
        plotly
        # sklearn-deap
      ]))
  ];

  # LD_LIBRARY_PATH
  env.LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
    pkgs.stdenv.cc.cc.lib
    pkgs.stdenv.cc.cc
    pkgs.git-crypt
    # sometimes you might need something additional like the following - you will get some useful error if it is looking for a binary in the environment.
    pkgs.taglib
    pkgs.openssl
    pkgs.git
    pkgs.libxml2
    pkgs.libxslt
    pkgs.libzip
    pkgs.zlib
    pkgs.libz
    pkgs.libffi # numpy uses libffi for some features
  ];

  # Workaround: make vscode's python extension read the .venv
  shellHook = ''
    echo "Activating virtual environment"
    # install pkgs that are not available in nixpkgs but are available in pypi here using pip install
    # pip install


    venv="$(cd $(dirname $(which python)); cd ..; pwd)"
    ln -Tsf "$venv" .venv
  '';
}
