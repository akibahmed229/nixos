# overlay pull the latest version of discord
{ inputs, ... }: (final: prev: {
  discord = prev.discord.overrideAttrs (
    _: {
      src = builtins.fetchTarball {
        url = "https://discord.com/api/download?platform=linux&format=tar.gz";
        sha256 = "sha256:0lgpz1a3qi02nhigqy3znqylb4x3g31diqxfps9zlxjjdv68qm3p";
      };
    }
  );
})

