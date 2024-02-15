{ system, pkgs ? import <nixpkgs> { }, unstable, inputs }:

pkgs.mkShell {
  name = "python-dev-environment";
  packages = [
    (pkgs.python311.withPackages (python-pkgs: [
      #python-pkgs.pygame
    ]))
  ];

  nativeBuildInputs = (with pkgs; [
    python311Packages.pygame
    python311Packages.pip

    #inputs.python27-pkgs.legacyPackages.${system}.python27Packages.pygame_sdl2
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
  # ...
}

