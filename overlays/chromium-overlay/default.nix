# overlay pull the latest version of chromium from the official website
{inputs, ...}: (final: prev: {
  chromium = prev.chromium.overrideAttrs {
    chromeSrc = builtins.fetchurl {
      url = "https://download-chromium.appspot.com/dl/Linux_x64?type=snapshots";
      sha256 = "sha256:0hl6s91g6x8rwxv7sd6p2213jk4jf5xk8w1s9mwjjrxdv0nspdjq";
    };
  };
})
