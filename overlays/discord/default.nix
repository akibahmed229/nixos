# overlay pull the latest version of discord
{ inputs, ... }: (final: prev: {
  discord = prev.discord.overrideAttrs (
    _: {
      src = builtins.fetchTarball {
        url = "https://discord.com/api/download?platform=linux&format=tar.gz";
        sha256 = "sha256:1byhpripbpq210mja0jswcmc4iwi1kfmhqq0x169x872ad47wrgm";
      };
    }
  );
})

