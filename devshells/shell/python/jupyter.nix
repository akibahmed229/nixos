{ pkgs  }:

pkgs.mkShell rec {
  name = "impurePythonEnv";
  venvDir = "./.venv";
  nativeBuildInputs =  with pkgs; [

    pkgs.stdenv.cc.cc.lib

    git-crypt
    stdenv.cc.cc # jupyter lab needs

    python3

    python311Packages.python
    python311Packages.ipykernel
    python311Packages.jupyterlab
    python311Packages.pyzmq
    python311Packages.venvShellHook
    python311Packages.pip
    python311Packages.numpy
    python311Packages.pandas
    python311Packages.requests

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
