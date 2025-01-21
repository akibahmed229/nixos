{unstable}: let
  pkgs = unstable.override {config.android_sdk.accept_license = true;};
  buildToolsVersion = "34.0.0";
  androidComposition = pkgs.androidenv.composeAndroidPackages {
    buildToolsVersions = [buildToolsVersion "28.0.3"];
    platformVersions = ["34" "28"];
    abiVersions = ["armeabi-v7a" "arm64-v8a"];
  };
  androidSdk = androidComposition.androidsdk;
in
  pkgs.mkShell {
    name = "flutter-shell";
    ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
    buildInputs = with unstable; [
      flutter
      androidSdk # The customized SDK that we've made above
      jdk17
    ];
  }
