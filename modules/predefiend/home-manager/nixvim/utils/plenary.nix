{pkgs, ...}: {
  programs.nixvim.extraPlugins = with pkgs.vimPlugins; [
    plenary-nvim
  ];
}
