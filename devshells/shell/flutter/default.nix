{unstable}: let
  buildToolsVersion = "33.0.1";
  androidComposition = unstable.androidenv.composeAndroidPackages {
    buildToolsVersions = [
      buildToolsVersion
      "35.0.0"
    ];
    platformVersions = [
      "33"
      "35"
    ];
    abiVersions = ["armeabi-v7a" "arm64-v8a"];
    extraLicenses = [
      "android-googletv-license"
      "android-sdk-arm-dbt-license"
      "android-sdk-license"
      "android-sdk-preview-license"
      "google-gdk-license"
      "intel-android-extra-license"
      "intel-android-sysimage-license"
      "mips-android-sysimage-license"
    ];
  };
  androidSdk = androidComposition.androidsdk;
in
  unstable.mkShell {
    name = "flutter-shell";
    ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
    GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${androidSdk}/libexec/android-sdk/build-tools/31.0.0/aapt2";
    PKG_CONFIG_PATH = "${unstable.sysprof}/lib/pkgconfig";
    CHROME_EXECUTABLE = "$HOME/.nix-profile/bin/google-chrome-stable";
    ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
    JAVA_HOME = "${unstable.jdk17}";

    buildInputs = with unstable; [
      flutter
      androidSdk
      jdk17
      firebase-tools
      cmake
      ninja
      pkg-config
      glib
      gtk3
      graphite2
      libnotify
      gdk-pixbuf
      sysprof
      atkmm
    ];
  }
