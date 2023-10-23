{ lib, pkgs, ... }:
{
  nvim = import ./nvchad { inherit lib pkgs; };
}
