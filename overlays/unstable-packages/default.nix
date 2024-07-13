# When applied, the unstable nixpkgs set (declared in the flake inputs) will
# be accissible through `pkgs.unstable`
{inputs, ...}: (final: prev: {
  unstable = import inputs.nixpkgs-unstable {
    inherit (final) system;
    config.allowUnfree = true;
  };
})
