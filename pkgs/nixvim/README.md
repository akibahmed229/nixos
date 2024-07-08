## How to Run

You can run this directly from the command line with:
```shell
nix run github:akibahmed229/nixvim
```

You can also plug this into a flake to include it into a system configuration.
```nix
{
  inputs = {
    nixvim.url = "github:akibahmed229/nixvim";
  };
}
```

This input can then be used as an overlay to replace the default neovim.
```nix
{ nixvim, ... }:
{
    overlays = (final: prev: {
      neovim = nixvim.packages.${prev.system}.default;
    });
}
```
