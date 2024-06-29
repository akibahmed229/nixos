# Reusable home-manager modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
# These should be stuff you would like to share with others, not your personal configurations.
{
  # Import the modules from the files in this directory
  monitors = import ./monitor;
  theme = import ./theme;

  # by default, import all the modules
  default.imports =
    [(import ./monitor)]
    ++ [(import ./theme)];
}
