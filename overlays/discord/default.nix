# overlay pull the latest version of discord
{ inputs, ... }: (final: prev: {
  discord = prev.discord.overrideAttrs (
    _: {
      src = builtins.fetchTarball {
        url = "https://discord.com/api/download?platform=linux&format=tar.gz";
        sha256 = "sha256:00rhcra846m6walm10y4352c3gibd4p82czsvklgafbcxs84zndq";
      };
    }
  );
})

