-- ENABLE
vim.opt.rtp:prepend("~/.config/nvim/lazy/lazy.nvim")
vim.opt.termguicolors = true
vim.g.mapleader = " "

-- DISABLE
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.cmd("syntax off")
vim.cmd("highlight clear")
vim.cmd("colorscheme default")
vim.o.background = "dark"
vim.api.nvim_set_hl(0, "Normal", { fg = "#ffffff", bg = "#000000", bold = true })
for _, group in ipairs(vim.fn.getcompletion("@", "highlight")) do pcall(vim.api.nvim_set_hl, 0, group, {}) end

-- LAZY
require("lazy").setup(
{
	{"hrsh7th/nvim-cmp"},
	{"hrsh7th/cmp-nvim-lsp"},
	{"hrsh7th/cmp-buffer"},
	{"hrsh7th/cmp-path"},
	{"L3MON4D3/LuaSnip"},
	{"saadparwaiz1/cmp_luasnip"},
	{"rafamadriz/friendly-snippets"},
	{"neovim/nvim-lspconfig"},
	{"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function() require('nvim-treesitter.configs').setup {
				ensure_installed = { "go", "lua", "typescript", "javascript", "cpp" },
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = false,
				},
				semantic_tokens = {
					enable = true,
				},
			}
		end,
	},
	{"nvim-treesitter/playground",
		cmd = { "TSPlaygroundToggle", "TSHighlightCapturesUnderCursor" },
		dependencies = { "nvim-treesitter/nvim-treesitter" },
	},
	{"nvim-tree/nvim-tree.lua",
		config = function() require("nvim-tree").setup({
				view = {
					float = {
						enable = true,
						open_win_config = function()
							local screen_w = vim.opt.columns:get()
							local screen_h = vim.opt.lines:get()
							local width = math.floor(screen_w * 0.5)
							local height = math.floor(screen_h * 0.5)
							local row = math.floor((screen_h - height) / 2 - 1) -- -1 for cmdline
							local col = math.floor((screen_w - width) / 2)
							return {
								relative = "editor",
								border = "rounded",
								width = width,
								height = height,
								row = row,
								col = col,
							}
						end,
					},
				},
				update_focused_file = { enable = true },
				filesystem_watchers = {
					enable = true,
					debounce_delay = 50,
				},
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
								open = "v",
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
				on_attach = function(bufnr)
					local api = require("nvim-tree.api")
					local function opts(desc)
						return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
					end
					vim.keymap.set('n', 'a', api.fs.create, opts('Create'))
					vim.keymap.set('n', 'r', api.fs.rename, opts('Rename'))
					vim.keymap.set('n', 'd', function()
						api.fs.remove()
						api.tree.reload()
					end, opts('Delete'))
					vim.keymap.set('n', 'c', api.fs.copy.node, opts('Copy'))
					vim.keymap.set('n', 'p', function()
						api.fs.paste()
						api.tree.reload()
					end, opts('Paste'))
					vim.keymap.set("n", "q", api.node.open.edit, opts("Open"))
					vim.keymap.set('n', 'Q', function()
						local node = api.tree.get_node_under_cursor()
						if node then
							if node.type == 'directory' then
								api.tree.change_root_to_node(node)
							end
						end
					end, opts('Set root to node under cursor'))
					vim.keymap.set("n", "R", api.tree.reload, opts("Refresh"))
					vim.keymap.set("n", "<CR>", "<Nop>", { buffer = bufnr })
				end,
			})
		end
	}
})

local luasnip = require("luasnip")
local s = luasnip.snippet
local t = luasnip.text_node
luasnip.add_snippets("go", {
	s("ien", {
		t("if err != nil {"),
		t({"", "\treturn err"}),
		t({"", "}"}),
	}),
})
local cmp = require("cmp")
local capabilities = require("cmp_nvim_lsp").default_capabilities()
capabilities.textDocument.semanticTokens = nil
vim.lsp.config("clangd", {
	capabilities = capabilities,
	filetypes = {"cpp"},
	cmd = {"clangd"},
})
vim.lsp.config("gopls", {
	capabilities = capabilities
})
vim.lsp.config("ts_ls", {
	capabilities = capabilities,
	filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
})
vim.lsp.enable({"clangd"})
vim.lsp.enable({"gopls"})
vim.lsp.enable({"ts_ls"})

cmp.setup(
{
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
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
		{name = "luasnip", keyword_length = 3},
		{name = "buffer", keyword_length = 4},
		{name = "path"},
	},
})

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		local stats = vim.loop.fs_stat(vim.fn.argv(0))
		if stats and stats.type == "directory" then
			require("nvim-tree.api").tree.open()
		end
	end
})

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = false
vim.opt.swapfile = false

vim.keymap.set('n', '<C-q>', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<C-e>', function() vim.diagnostic.open_float() end, { silent = true })
vim.keymap.set('n', '<leader>yy', '"+yy', { noremap = true, silent = true })
vim.keymap.set('v', '<leader>y', '"+y', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>p', '"+p', { noremap = true, silent = true })


-- THEME
vim.cmd [[
	hi clear NvimTreeNormal
	hi clear NvimTreeFolderName
	hi clear NvimTreeOpenedFolderName
	hi clear NvimTreeEmptyFolderName
	hi clear NvimTreeIndentMarker
	hi clear NvimTreeGitDirty
	hi clear NvimTreeGitNew
	hi clear NvimTreeGitDeleted
	hi clear NvimTreeSpecialFile
	hi clear NvimTreeImageFile
	hi clear NvimTreeSymlink
	hi clear NvimTreeExecFile
	hi clear NvimTreeRootFolder
]]


vim.api.nvim_set_hl(0, "NvimTreeClosedFolderIcon",	{ fg = "#ffffff", bg = "NONE", })
vim.api.nvim_set_hl(0, "NvimTreeClosedFolderName",	{ fg = "#ffffff", bg = "NONE", })
vim.api.nvim_set_hl(0, "NvimTreeOpenedFolderIcon",	{ fg = "#ffffff", bg = "NONE", bold = true })
vim.api.nvim_set_hl(0, "NvimTreeOpenedFolderName",	{ fg = "#ffffff", bg = "NONE", })
vim.api.nvim_set_hl(0, "NvimTreeFolderName",		{ fg = "#ffffff", bg = "NONE", })
vim.api.nvim_set_hl(0, "NvimTreeFileIcon",		{ fg = "#ffffff", bg = "NONE", bold = true})
vim.api.nvim_set_hl(0, "NvimTreeEmptyFolderName",	{ fg = "#ff9999", bg = "NONE", })


vim.api.nvim_set_hl(0, "CmpPmenu",       { bg = "#000000", fg = "#ffffff" })
vim.api.nvim_set_hl(0, "CmpPmenuThumb",  { bg = "#ffffff" })
vim.api.nvim_set_hl(0, "CmpPmenuSbar",   { bg = "#000000" })
vim.api.nvim_set_hl(0, "CmpItemAbbr",    { fg = "#ffffff" })
vim.api.nvim_set_hl(0, "CmpItemAbbrMatch", { fg = "#ffffff"})
vim.api.nvim_set_hl(0, "CmpItemKind",    { fg = "#7f7f7f", italic = true })
vim.api.nvim_set_hl(0, "CmpItemMenu",    { fg = "#7f7f7f", italic = true })
vim.api.nvim_set_hl(0, "CmpPmenuSel",    { bg = "#00ffff", fg = "#000000", bold = true })

vim.api.nvim_create_user_command("What", "TSHighlightCapturesUnderCursor", {})

vim.api.nvim_set_hl(0, "Normal",		{ fg = "#ffffff", bg = "NONE"})

vim.api.nvim_set_hl(0, "LineNr",		{ fg = "#999999", bg = "NONE" })
--vim.api.nvim_set_hl(0, "LineNr",		{ fg = "#ff0000", bg = "NONE" })

vim.api.nvim_set_hl(0, "StatusLine",		{ fg = "#000000", bg = "#ffffff", bold = true })
vim.api.nvim_set_hl(0, "StatusLineNC",		{ fg = "#ffffff", bg = "#000000" })

vim.api.nvim_set_hl(0, '@keyword',		{ fg = "#ffffff", bold = true })
vim.api.nvim_set_hl(0, '@number',		{ fg = "#ffffff", bold = true })
vim.api.nvim_set_hl(0, '@string',		{ fg = "#ffffff", bold = true })
vim.api.nvim_set_hl(0, '@type',			{ fg = "#26ff00", bold = true })
-- disabled
vim.api.nvim_set_hl(0, '@function.method.call',	{ fg = "#26ff00", bold = false })
vim.api.nvim_set_hl(0, '@function.call',	{ fg = "#26ff00", bold = false })


-- TERM
vim.api.nvim_create_autocmd('TermOpen', {
	group = vim.api.nvim_create_augroup('custom-term-open', { clear = true }),
	callback = function()
		vim.cmd("startinsert")
		vim.opt.number = false
		vim.opt.relativenumber = false
	end,
})

vim.keymap.set("n", "<leader><Cr>", function()
	vim.cmd.vnew()
	vim.cmd.term()
	vim.cmd.wincmd("J")
	vim.api.nvim_win_set_height(0, 8)
	vim.api.nvim_win_set_option(0, 'winhighlight', 'Normal:TermBg')
	vim.cmd('highlight TermBg guibg=#141414')
end)
