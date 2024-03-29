{ pkgs ? import <nixpkgs> { }
, imgLink ? { url = "https://raw.githubusercontent.com/akibahmed229/nixos/main/public/wallpaper/Photo-of-Valley.jpg"; sha256 = "sha256-86ja7yfSdMAaFFdfDqQS8Yq5yjZjXPMLTIgExcnzbXc="; }
, ...
}:

let
  isValidUrl = url: builtins.match ''(https?|ftp)://[^\s/$.?#].*'' url != null;

  image =
    if isValidUrl imgLink.url then
      pkgs.fetchurl
        {
          inherit (imgLink) url;
          inherit (imgLink) sha256;
        }
    else
    # what should be assigned to a
      throw "Invalid URL. Please provide a valid URL.";
in
pkgs.stdenv.mkDerivation {
  name = "sddm-theme";
  #src = pkgs.fetchFromGitHub {
  #  owner = "MarianArlt";
  #  repo = "sddm-sugar-dark";
  #  rev = "ceb2c455663429be03ba62d9f898c571650ef7fe";
  #  sha256 = "0153z1kylbhc9d12nxy9vpn0spxgrhgy36wy37pk6ysq7akaqlvy";
  #};

  src = pkgs.fetchFromGitHub {
    owner = "gpskwlkr";
    repo = "sddm-astronaut-theme";
    rev = "468a100460d5feaa701c2215c737b55789cba0fc";
    sha256 = "1h20b7n6a4pbqnrj22y8v5gc01zxs58lck3bipmgkpyp52ip3vig";
  };

  installPhase = ''
    mkdir -p $out
    cp -R ./* $out/
    cd $out/
    rm Backgrounds/background.png
    cp -r ${image} $out/Backgrounds/background.png
  '';

  meta = with pkgs.lib; {
    description = "A dark theme for SDDM";
    homepage = "https://github.com/MarianArlt/sddm-sugar-dark";
    platforms = platforms.linux;
    maintainers = [ maintainers.akibahmed229 ];
    license = licenses.gpl3;
  };
}
