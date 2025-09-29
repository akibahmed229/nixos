{
  description = "Dev Environment for RepairShop Flutter App";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    akibLibSrc = {
      url = "github:akibahmed229/nixos";
      flake = false; # Keeps the dependency graph small, as intended
    };
  };

  outputs = {
    nixpkgs,
    akibLibSrc,
    ...
  }: let
    # --- 1. Setup Library & Imports ---
    lib = nixpkgs.lib;

    # Import the helper function from the source path
    akibLib = import "${akibLibSrc}/lib" {inherit lib;};
    inherit (akibLib) forAllSystems; # Extract the helper function

    # Common variables
    buildToolsVersion = "35.0.0";
  in {
    # --- 2. Apply Helper to Generate DevShells for All Systems ---
    devShells = forAllSystems (
      system: let
        # pkgs and Android configuration MUST be defined inside 'perSystem'
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            # Note: For Darwin (macOS), android_sdk.accept_license is usually ignored/unnecessary
            android_sdk.accept_license = true;
          };
        };

        # Default JDK vesion
        javaPackage = pkgs.jdk17;

        # Android SDK Configuration (Linux/Darwin only)
        androidComposition = pkgs.androidenv.composeAndroidPackages {
          buildToolsVersions = [
            buildToolsVersion
            "35.0.0"
          ];
          platformVersions = [
            "34"
            "35"
          ];
          ndkVersions = ["27.0.12077973"];
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

        # List of packages that are specific to the host OS
        hostPackages = with pkgs;
          if system == "x86_64-darwin" || system == "aarch64-darwin"
          then [
            # macOS-specific Flutter dependencies (optional, but good practice)
            # Flutter often relies on system libraries, but we ensure core tools are available.
            xcodebuild
          ]
          else [
            # Linux-specific Flutter desktop dependencies
            pkg-config
            glib
            gtk3
            graphite2
            libnotify
            gdk-pixbuf
            sysprof
            atkmm
          ];

        # List of packages common to all systems
        commonPackages = with pkgs;
          [
            flutter
            androidSdk
            javaPackage # Using the common jdk17 reference
            firebase-tools
            cmake
            ninja
            watchexec
            fswatch
            mesa-demos
            # pkgs.chromium is only available for some systems (Linux/Darwin)
            # Use lib.optionals to conditionally include it
          ]
          ++ lib.optionals (system != "i686-linux") [
            pkgs.chromium
          ];
      in {
        # The output must be wrapped in 'devShells' to comply with flake schema
        default = pkgs.mkShell {
          name = "flutter-shell-${system}";

          # Environment Variables
          ANDROID_SDK_ROOT = "${toString ./android-sdk}";
          ANDROID_HOME = "${toString ./android-sdk}";
          JAVA_HOME = "${javaPackage}";
          # PKG_CONFIG_PATH is only relevant on Linux
          PKG_CONFIG_PATH = lib.optionalString (pkgs.stdenv.isLinux) "${pkgs.sysprof}/lib/pkgconfig";
          # CHROME_EXECUTABLE is conditional
          CHROME_EXECUTABLE = lib.optionalString (builtins.elem pkgs.chromium commonPackages) "${pkgs.chromium}/bin/chromium";

          buildInputs = commonPackages ++ hostPackages;

          shellHook = ''
            export PS1="[flutter-shell] > "
            echo -e "\n🛠️ Entering Flutter Devshell for ${system}\n"

            # Ensure Android SDK is set up in a writable directory
            export ANDROID_SDK_ROOT=$(pwd)/android-sdk
            export ANDROID_HOME=$ANDROID_SDK_ROOT
            export JAVA_HOME=${javaPackage}

            # Conditionally set CHROME_EXECUTABLE for web builds
            ${lib.optionalString (builtins.elem pkgs.chromium commonPackages) "export CHROME_EXECUTABLE=${pkgs.chromium}/bin/chromium"}

            # Copy SDK files to writable directory if not already present
            if [ ! -d "$ANDROID_SDK_ROOT" ]; then
              echo "Setting up writable Android SDK..."
              mkdir -p "$ANDROID_SDK_ROOT"
              cp -r ${androidSdk}/libexec/android-sdk/* "$ANDROID_SDK_ROOT/"
              chmod -R u+w "$ANDROID_SDK_ROOT"
            fi

            # Generate local.properties for Gradle
            if [ -d "./android" ]; then
              echo "sdk.dir=$ANDROID_SDK_ROOT" > ./android/local.properties
            fi

            # Configure Flutter
            flutter config --jdk-dir="$JAVA_HOME"
            flutter config --enable-web
            flutter doctor

            echo -e "\n✅ Ready to build for Android, Web, and ${
              if pkgs.stdenv.isDarwin
              then "macOS"
              else "Linux"
            }\n"
          '';
        };
      }
    );
  };
}
