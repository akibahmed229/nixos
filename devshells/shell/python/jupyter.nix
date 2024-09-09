{
  pkgs ? import <nixpkgs> {},
  system,
  unstable,
  inputs,
}:
pkgs.mkShell {
  name = "DataScience-dev-environment";

  nativeBuildInputs =
    (with pkgs; [
      pkgs.stdenv.cc.cc.lib
      git-crypt
      stdenv.cc.cc # jupyter lab needs
      # sometimes you might need something additional like the following - you will get some useful error if it is looking for a binary in the environment.
      taglib
      openssl
      git
      libxml2
      libxslt
      libzip
      zlib
    ])
    ++ (with unstable.python311Packages; [
      virtualenv
      pip
      ipykernel
      jupyterlab
      pyzmq
      venvShellHook
      pip
      numpy
      pandas
      pandas-datareader
      matplotlib
      requests
      seaborn
      openpyxl
      cufflinks
      plotly
      # sklearn-deap
    ]);

  # Workaround: make vscode's python extension read the .venv
  shellHook = ''
    echo "Activating virtual environment"
    # install pkgs that are not available in nixpkgs but are available in pypi here using pip install
    # pip install


    venv="$(cd $(dirname $(which python)); cd ..; pwd)"
    ln -Tsf "$venv" .venv
  '';
}
