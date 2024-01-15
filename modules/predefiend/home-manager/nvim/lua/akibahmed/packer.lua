-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  use {
	  'nvim-telescope/telescope.nvim', tag = '0.1.2',
	  -- or                            , branch = '0.1.x',
	  requires = { {'nvim-lua/plenary.nvim'} }
  }

  use({ 'rose-pine/neovim', 
  as = 'rose-pine',
  config = function()
	  vim.cmd('colorscheme rose-pine')
  end
   })
 
   use('nvim-treesitter/nvim-treesitter', {run = ':TSUpdate'})
   use('nvim-treesitter/playground')
   use('ThePrimeagen/harpoon')
   use('mbbill/undotree')
   use('tpope/vim-fugitive')
   use('tpope/vim-surround') -- Surrounding (ysw)
   use('preservim/nerdtree') -- NerdTree
   use('vim-airline/vim-airline') -- Status bar
   use('ap/vim-css-color') -- CSS Color Preview
   use('rafi/awesome-vim-colorschemes') -- Retro Scheme
   use('ryanoasis/vim-devicons') -- Developer Icons 
   use('https://github.com/tc50cal/vim-terminal')  -- Vim Terminal

   use {
	   'VonHeikemen/lsp-zero.nvim',
	   branch = 'v2.x',
	   requires = {
		   -- LSP Support
		   {'neovim/nvim-lspconfig'},             -- Required
		   {                                      -- Optional
		   'williamboman/mason.nvim',
		   run = function()
			   pcall(vim.cmd, 'MasonUpdate')
		   end,
	   },
	   {'williamboman/mason-lspconfig.nvim'}, -- Optional

	   -- Autocompletion
	   {'hrsh7th/nvim-cmp'},     -- Required
	   {'hrsh7th/cmp-nvim-lsp'}, -- Required
	   {'L3MON4D3/LuaSnip'},     -- Required
   }
}

 end)
