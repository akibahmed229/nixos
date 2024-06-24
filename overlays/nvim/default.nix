{ inputs, ... }:(final: prev: {
      neovim = inputs.nixvim.packages.${prev.system}.default;
})
