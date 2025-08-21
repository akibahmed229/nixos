{pkgs, ...}: {
  programs.nixvim = {
    plugins = {
      treesitter = {
        enable = true;
        folding = false;
        settings = {
          highlight.enable = true;
          indent.enable = true;
          ensure_installed = ["c" "lua" "vim" "vimdoc" "query" "elixir" "heex" "javascript" "html" "nix" "python" "rust" "css" "sql" "java" "json" "typescript" "yaml" "toml" "bash"];
        };
        nixvimInjections = true;
        languageRegister.nu = "nu";
        grammarPackages = with pkgs;
          vimPlugins.nvim-treesitter.passthru.allGrammars
          ++ (with tree-sitter-grammars; [tree-sitter-nu]);
      };
    };
  };
}
