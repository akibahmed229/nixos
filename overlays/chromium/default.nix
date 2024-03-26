# overlay pull the latest version of chromium from the official website
{ inputs, ... }: (final: prev: {
  chromium = prev.chromium.overrideAttrs {
    chromeSrc = builtins.fetchurl {
      url = "https://download-chromium.appspot.com/dl/Linux_x64?type=snapshots";
      sha256 = "sha256:1q6pk5bwbij6b8y1p7y806rxrak0chds5r3mxhyx4lcpk7hfiwkr";
    };
  };
})

