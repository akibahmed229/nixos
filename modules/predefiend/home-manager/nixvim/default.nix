{inputs, ...}: {
  # Import all your configuration modules here
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
    ./core
    ./ui
    ./lsp
    ./telescope
    ./treesitter
    ./bufferlines
    ./statusline
    ./file-tree
    ./git
    ./none-ls
    ./snippets
    ./completion
    ./utils
  ];

  programs.nixvim = {
    enable = true;
  };
}
