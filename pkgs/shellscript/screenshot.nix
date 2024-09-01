{pkgs ? import <nixpkgs> {}}:
pkgs.writeShellApplication {
  name = "screenshot";

  runtimeInputs = with pkgs; [
    grim
    slurp
    swappy
  ];

  text = ''
    #!/usr/bin/env bash

    # check if swappy is installed then use it, otherwise use the one from nixpkgs
    swappy=$(command -v swappy || ${pkgs.swappy}/bin/swappy)

    # take a screenshot and pipe it to swappy
    grim -g "$(slurp)" - | "$swappy" -f -
  '';
}
