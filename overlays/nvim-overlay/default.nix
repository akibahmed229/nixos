{inputs, ...}: (final: prev: {
  neovim = inputs.self.packages.${final.system}.nixvim;
})
