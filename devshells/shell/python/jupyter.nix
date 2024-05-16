{ pkgs ? import <nixpkgs> { } }:

let
  pythonPackages = pkgs.python311Packages; # Change to Python 3.11
in
pkgs.mkShell rec {
  name = "impurePythonEnv";
  venvDir = "./.venv";
  buildInputs =  [

    pkgs.stdenv.cc.cc.lib

    git-crypt
    # stdenv.cc.cc # jupyter lab needs

    python3

    pythonPackages.python
    pythonPackages.ipykernel
    pythonPackages.jupyterlab
    pythonPackages.pyzmq
    pythonPackages.venvShellHook
    pythonPackages.pip
    pythonPackages.numpy
    pythonPackages.pandas
    pythonPackages.requests

    # sometimes you might need something additional like the following - you will get some useful error if it is looking for a binary in the environment.
    taglib
    openssl
    git
    libxml2
    libxslt
    libzip
    zlib

  ];

  # Run this command, only after creating the virtual environment
  postVenvCreation = ''
    unset SOURCE_DATE_EPOCH
    
    python -m ipykernel install --user --name=numpy-env --display-name="numpy-env"
    pip install -r requirements.txt
  '';

  # Now we can execute any commands within the virtual environment.
  # This is optional and can be left out to run pip manually.
  postShellHook = ''
    # allow pip to install wheels
    unset SOURCE_DATE_EPOCH
  '';
}
