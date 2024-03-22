{ inputs, ... }: (self: super: {
  discord = super.discord.overrideAttrs (
    _: {
      src = builtins.fetchTarball {
        url = "https://discord.com/api/download?platform=linux&format=tar.gz";
        sha256 = "sha256:1m7wrqgfkygn7v2arm68h68nf4kfv3pqvdapwxq4w11ndj6q1bs3";
      };
    }
  );
})

