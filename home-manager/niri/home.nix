{
  pkgs,
  lib,
  config,
  self,
  ...
}: let
  niriConfig = "$FLAKE_DIR/home-manager/niri/niri";
  niriTarget = "${config.home.homeDirectory}/.config/niri";
in {
  home.packages = with pkgs; [
    # For niri
    xwayland-satellite
  ];

  home.activation.symlinkNiriWMConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ln -sfn "${niriConfig}" "${niriTarget}"
  '';
}
