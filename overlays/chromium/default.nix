# overlay pull the latest version of chromium from the official website
{ inputs, ... }: (final: prev: {
  chromium = prev.chromium.overrideAttrs {
    chromeSrc = builtins.fetchurl {
      url = "https://download-chromium.appspot.com/dl/Linux_x64?type=snapshots";
      sha256 = "sha256:1h7qgqinmrl4w2a1871x2qgdpibzbcss59z2ar4d10pqfkcgl9kv";
    };
  };
})

