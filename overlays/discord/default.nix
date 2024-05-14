# overlay pull the latest version of discord
{ inputs, ... }: (final: prev: {
  discord = prev.discord.overrideAttrs (
    _: {
      src = builtins.fetchTarball {
        url = "https://discord.com/api/download?platform=linux&format=tar.gz";
        sha256 = "sha256:0fgip42bwgkmskx0in7z4v6rsnk7x1wgiv73s4qp9jiyyd1x012w";
      };
    }
  );
})

