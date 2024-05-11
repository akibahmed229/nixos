# overlay pull the latest version of discord
{ inputs, ... }: (final: prev: {
  discord = prev.discord.overrideAttrs (
    _: {
      src = builtins.fetchTarball {
        url = "https://discord.com/api/download?platform=linux&format=tar.gz";
        sha256 = "sha256:13d3sqx3yj8vgzj6r4wxky7iwl3phx9rrvi77s5jxdi51i4v6gns";
      };
    }
  );
})

