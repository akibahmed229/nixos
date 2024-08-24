# overlay pull the latest version of discord
{inputs, ...}: (final: prev: {
  discord = prev.discord.overrideAttrs (
    _: {
      src = builtins.fetchTarball {
        url = "https://discord.com/api/download?platform=linux&format=tar.gz";
        sha256 = "sha256:0k9sk5pmjw7xq68h2s80q8fg48p31albrqrqafmmrxik5f8f96rn";
      };
    }
  );
})
