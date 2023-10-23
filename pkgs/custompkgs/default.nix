{pkgs, ...}:
{
  nvim = import ./nvchad { inherit pkgs; };
}
