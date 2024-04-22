# overlay pull the latest version of discord
{ inputs, ... }: (final: prev: {
  discord = prev.discord.overrideAttrs (
    _: {
      src = builtins.fetchTarball {
        url = "https://discord.com/api/download?platform=linux&format=tar.gz";
        sha256 = "sha256:0hvgzn8zfg6wqhsjcg9icd9y7vcd5h4ffckmc0ga51iv6ic35nyz";
      };
    }
  );
})

