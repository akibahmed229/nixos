{pkgs ? import <nixpkgs> {}}:
pkgs.writeShellApplication {
  name = "wallpaper";

  runtimeInputs = with pkgs; [
    swww
  ];

  text = ''
    # Directory containing the images
    IMAGE_DIR="$WALLPAPER"

    # Launch sxiv to select an image and capture the selected image's filename
    SELECTED_IMAGE=$(nsxiv -t -o "$IMAGE_DIR"/* | head -n 1)

    # Check if an image was selected
    if [ -n "$SELECTED_IMAGE" ]; then
      # Print the relative path of the selected image
      RELATIVE_PATH="$SELECTED_IMAGE"
    else
      echo "No image selected."
    fi

     # copy the image to cache folder and save the img as Wallpaper
     cp "$RELATIVE_PATH" ~/.cache/swww/Wallpaper

     # Use the selected image path with swww command
     swww img "$RELATIVE_PATH"  --transition-step 2 --transition-fps 75 --transition-type right
  '';
}
