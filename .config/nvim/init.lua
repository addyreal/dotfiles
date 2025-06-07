vim.opt.rtp:prepend("~/.config/nvim/lazy/lazy.nvim")

require("lazy").setup(
{
	{"neovim/nvim-lspconfig"},

	{"hrsh7th/nvim-cmp"},
	{"hrsh7th/cmp-nvim-lsp"},
	{"hrsh7th/cmp-buffer"},
	{"hrsh7th/cmp-path"},
	{"L3MON4D3/LuaSnip"},
	{"saadparwaiz1/cmp_luasnip"},
	{"rafamadriz/friendly-snippets"},

	{
		"nvim-tree/nvim-tree.lua",
		config = function()
			require("nvim-tree").setup({
				view = { width = 30 },
				update_focused_file = { enable = true },
				renderer = {
					icons = {
						show = {
							file = true,
							folder = true,
							folder_arrow = false,
							git = false,
						},
						glyphs = {
							default = "$",
							folder = {
								default = ">",
								open = ">",
								empty = ">",
								empty_open = ">",
								symlink = ">",
								symlink_open = ">",
							},
							git = {
								unstaged = "",
								staged = "",
								unmerged = "",
								renamed = "",
								untracked = "",
								deleted = "",
								ignored = "",
							},
						},
					},
				},
				filters = { dotfiles = false },
			})
		end
	}
})

local lspconfig = require("lspconfig")
local cmp = require("cmp")
local luasnip = require("luasnip")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

require("luasnip.loaders.from_vscode").lazy_load()

lspconfig.clangd.setup({capabilities = capabilities})
lspconfig.gopls.setup({capabilities = capabilities})
lspconfig.ts_ls.setup({capabilities = capabilities})

cmp.setup(
{
	snippet =
	{
		expand = function(args) luasnip.lsp_expand(args.body) end,
	},
	mapping = cmp.mapping.preset.insert(
	{
		["<Tab>"] = cmp.mapping.select_next_item(),
		["<S-Tab>"] = cmp.mapping.select_prev_item(),
		["<CR>"] = cmp.mapping.confirm({select = true}),
		["<C-Space>"] = cmp.mapping.complete(),
	}),
	sources =
	{
		{name = "nvim_lsp"},
		{name = "luasnip"},
		{name = "buffer"},
		{name = "path"},
	},
})

vim.keymap.set('n', '<C-e>', function() vim.diagnostic.open_float() end, { silent = true })
vim.opt.number = true

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		local stats = vim.loop.fs_stat(vim.fn.argv(0))
		if stats and stats.type == "directory" then
			require("nvim-tree.api").tree.open()
		end
	end
})

vim.keymap.set('n', '<C-q>', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
