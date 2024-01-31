{ pkgs, ... }:

pkgs.writeShellScriptBin "wallpaper" ''
  # Get the selected image path using wofi
  image_path=$(ls ~/flake/public/wallpaper | ${pkgs.wofi}/bin/wofi -n --dmenu -i -p "Select Wallpaper" | awk '{print "public/wallpaper/"$1}')

  # Check if the user selected a valid image path
  if [ -z "$image_path" ]; then
      echo "No image selected. Exiting."
      exit 1
  fi

  # Use the selected image path with swww command
  ${pkgs.swww}/bin/swww img ~/flake/$image_path  --transition-step 2 --transition-fps 60 --transition-type right
''

