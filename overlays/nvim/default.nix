{inputs, ...}: (final: prev: {
  neovim = inputs.self.packages.${prev.system}.nixvim;
})
