{config, ...}: {
  # Username is inherited from the parent config
  inherit (config.nm.setUser) name;

  ####################  My custom module option will merge into default user ####################

  # Enable system + home-level configurations
  enSystemConf = false;
  enHomeConf = true;
}
