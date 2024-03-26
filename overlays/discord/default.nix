# overlay pull the latest version of discord
{ inputs, ... }: (final: prev: {
  discord = prev.discord.overrideAttrs (
    _: {
      src = builtins.fetchTarball {
        url = "https://discord.com/api/download?platform=linux&format=tar.gz";
        sha256 = "sha256:05gplcwx0i9rvjpi2v7749fhd11x08zk002p23g19j2nq86maw4k";
      };
    }
  );
})

