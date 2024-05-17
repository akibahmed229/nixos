{ system, pkgs ? import <nixpkgs> { }, unstable, inputs }:

pkgs.mkShell {
  name = "DataScience-dev-environment";

  nativeBuildInputs = (with pkgs; [
    pkgs.stdenv.cc.cc.lib

    git-crypt
    stdenv.cc.cc # jupyter lab needs

    python3

    python311Packages.ipykernel
    python311Packages.jupyterlab
    python311Packages.pyzmq
    python311Packages.venvShellHook
    python311Packages.pip
    python311Packages.numpy
    python311Packages.pandas
    python311Packages.pandas-datareader
    python311Packages.matplotlib
    python311Packages.requests

    # sometimes you might need something additional like the following - you will get some useful error if it is looking for a binary in the environment.
    taglib
    openssl
    git
    libxml2
    libxslt
    libzip
    zlib
  ]) ++
  (with unstable; [
    python311Packages.virtualenv
  ]);


  # Workaround: make vscode's python extension read the .venv
  shellHook = ''
    echo "Activating virtual environment"
    venv="$(cd $(dirname $(which python)); cd ..; pwd)"
    ln -Tsf "$venv" .venv
  '';
}
