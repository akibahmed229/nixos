# overlay pull the latest version of discord
{ inputs, ... }: (final: prev: {
  discord = prev.discord.overrideAttrs (
    _: {
      src = builtins.fetchTarball {
        url = "https://discord.com/api/download?platform=linux&format=tar.gz";
        sha256 = "sha256:151iklw4gb2y3drnp7k8rzrx3c329cpmzd9jhhdxvnwgj0w7j5pv";
      };
    }
  );
})

