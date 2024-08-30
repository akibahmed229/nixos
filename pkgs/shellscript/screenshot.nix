{pkgs ? import <nixpkgs> {}}:
pkgs.writeShellApplication {
  name = "screenshot";

  runtimeInputs = with pkgs; [
    grim
    slurp
    swappy
  ];

  text = ''
    grim -g "$(slurp)" - | swappy -f -
  '';
}
