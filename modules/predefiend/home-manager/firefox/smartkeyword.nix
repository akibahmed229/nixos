{
  # --- Nix ---
  "nix packages" = {
    urls = [
      {
        template = "https://search.nixos.org/packages";
        params = [
          {
            name = "type";
            value = "packages";
          }
          {
            name = "query";
            value = "{searchTerms}";
          }
        ];
      }
    ];
    definedAliases = ["@np"];
  };

  "nix options" = {
    urls = [
      {
        template = "https://search.nixos.org/options";
        params = [
          {
            name = "query";
            value = "{searchTerms}";
          }
        ];
      }
    ];
    definedAliases = ["@no"];
  };

  # --- YouTube ---
  "youtube" = {
    urls = [
      {
        template = "https://www.youtube.com/results";
        params = [
          {
            name = "search_query";
            value = "{searchTerms}";
          }
        ];
      }
    ];
    definedAliases = ["@yt"];
  };

  # --- npm packages ---
  "npm" = {
    urls = [
      {
        template = "https://www.npmjs.com/search";
        params = [
          {
            name = "q";
            value = "{searchTerms}";
          }
        ];
      }
    ];
    definedAliases = ["@npm"];
  };

  # --- Flutter pub.dev packages ---
  "flutter pub" = {
    urls = [
      {
        template = "https://pub.dev/packages";
        params = [
          {
            name = "q";
            value = "{searchTerms}";
          }
        ];
      }
    ];
    definedAliases = ["@fp"];
  };

  # --- Docker Hub images ---
  "docker hub" = {
    urls = [
      {
        template = "https://hub.docker.com/search";
        params = [
          {
            name = "q";
            value = "{searchTerms}";
          }
          {
            name = "type";
            value = "image";
          }
        ];
      }
    ];
    definedAliases = ["@dh" "@docker"];
  };
}
