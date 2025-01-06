{
  pkgs ? import <nixpkgs> {},
  imgLink ? {
    url = "https://raw.githubusercontent.com/akibahmed229/wallpaper/main/Photo-of-Valley.jpg";
    sha256 = "sha256-86ja7yfSdMAaFFdfDqQS8Yq5yjZjXPMLTIgExcnzbXc=";
  },
  sddm-astronaut-theme ? {
    enable = false;
    theme = "astronaut";
  },
  sugar-dark ? false,
  ...
}: let
  # check if the provided URL is valid
  isValidUrl = url: builtins.match ''(https?|ftp)://[^\s/$.?#].*'' url != null;

  #  fetch the image from the provided URL
  image =
    if isValidUrl imgLink.url
    then
      pkgs.fetchurl
      {
        inherit (imgLink) url;
        inherit (imgLink) sha256;
      }
    else
      # what should be assigned to a
      throw "Invalid URL. Please provide a valid URL.";

  # src contain different github repos for different themes
  src =
    if sugar-dark
    then
      pkgs.fetchFromGitHub {
        owner = "MarianArlt";
        repo = "sddm-sugar-dark";
        rev = "master";
        sha256 = "0153z1kylbhc9d12nxy9vpn0spxgrhgy36wy37pk6ysq7akaqlvy";
      }
    else if sddm-astronaut-theme.enable
    then
      pkgs.fetchFromGitHub {
        /*
        sddm qt6-svg qt6-virtualkeyboard qt6-multimedia-ffmpeg     # Arch
        sddm qt6-svg qt6-virtualkeyboard qt6-multimedia            # Void
        sddm qt6-qtsvg qt6-qtvirtualkeyboard qt6-qtmultimedia      # Fedora
        sddm-qt6 qt6-svg qt6-virtualkeyboard qt6-multimedia        # OpenSUSE
        */
        owner = "Keyitdev";
        repo = "sddm-astronaut-theme";
        rev = "master";
        sha256 = "sha256-gBSz+k/qgEaIWh1Txdgwlou/Lfrfv3ABzyxYwlrLjDk=";
      }
    else
      pkgs.fetchFromGitHub {
        owner = "gpskwlkr";
        repo = "sddm-astronaut-theme";
        rev = "master";
        sha256 = "1h20b7n6a4pbqnrj22y8v5gc01zxs58lck3bipmgkpyp52ip3vig";
      };
in
  pkgs.stdenv.mkDerivation {
    name = "sddmThemeByAKIB";
    inherit src;

    installPhase = ''
      mkdir -p $out
      cp -R ./* $out/
      cd $out/

      function setSddmAstronautTheme(){
        local theme=$1
        if [ -f "Themes/$theme.conf" ]; then
          sed -i "s;ConfigFile=Themes/astronaut.conf;ConfigFile=Themes/$theme.conf;" metadata.desktop
        else
          # if the theme is not found, set the default theme same as src (astronaut)
          echo "Theme not found"
        fi
      }

      echo "sugar-dark: ${toString sugar-dark}"
      echo "sddm-astronaut-theme.enable: ${toString sddm-astronaut-theme.enable}"
      echo "sddm-astronaut-theme.theme: ${sddm-astronaut-theme.theme}"
      echo "Source directory contents:"
      ls -R

      if [ "${toString sugar-dark}" = "1" ]; then
        rm -f Background.jpg
        cp -r ${image} $out/Background.jpg
      # sddm-astronaut-theme contain a series of themes that can be set
      elif [ "${toString sddm-astronaut-theme.enable}" = "1" ]; then
        setSddmAstronautTheme ${sddm-astronaut-theme.theme}
      else
        rm Backgrounds/background.png
        mkdir -p Backgrounds
        cp -r ${image} Backgrounds/background.png
      fi
    '';

    meta = with pkgs.lib; {
      description = "Theme for SDDM";
      homepage = [
        "https://github.com/MarianArlt/sddm-sugar-dark"
        "https://github.com/gpskwlkr/sddm-astronaut-theme"
        "https://github.com/Keyitdev/sddm-astronaut-theme"
      ];
      platforms = platforms.linux;
      maintainers = [maintainers.akibahmed229];
      license = licenses.gpl3;
    };
  }
