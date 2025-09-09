{
  pkgs,
  lib,
  config,
  ...
}: let
  niriConfig = "$FLAKE_DIR/home-manager/niri/niri";
  niriTarget = "${config.home.homeDirectory}/.config/niri";
in {
  home.activation.symlinkQuickshellConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ln -sfn "${niriConfig}" "${niriTarget}"
  '';
}
