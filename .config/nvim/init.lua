-- =============
-- OPTS
-- =============
vim.o.background = "dark"
vim.opt.rtp:prepend("~/.config/nvim/lazy/lazy.nvim")
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.termguicolors = true
vim.g.mapleader = " "
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1



-- =============
-- PLUGINS
-- =============
require("lazy").setup({
	{"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup({
				signs = {add = "+", change = "~", delete = "_"},
				attach_to_untracked = false,
				current_line_blame = true,
				current_line_blame_opts = {
					virt_text = true,
					delay = 500,
				},
				on_attach = function(bufnr)
					if vim.bo[bufnr].buftype ~= "" then return end
					local gs = package.loaded.gitsigns
					vim.keymap.set("n", "gg", gs.preview_hunk, {buffer = bufnr})
					vim.keymap.set("n", "gb", gs.blame_line, {buffer = bufnr})
					vim.keymap.set("n", "gd", function()
						gs.diffthis()
						local win = vim.api.nvim_get_current_win()
						local wins = vim.api.nvim_tabpage_list_wins(0)
						for _, w in ipairs(wins) do
							if w ~= win then
								vim.api.nvim_set_current_win(w)
								break
							end
						end
					end, {buffer = bufnr})
				end,
				preview_config = {
					border = "single",
				}
			})
		end,
	},
	{"hrsh7th/nvim-cmp"},
	{"hrsh7th/cmp-nvim-lsp"},
	{"hrsh7th/cmp-buffer"},
	{"hrsh7th/cmp-path"},
	{"L3MON4D3/LuaSnip"},
	{"saadparwaiz1/cmp_luasnip"},
	{"rafamadriz/friendly-snippets"},
	{"neovim/nvim-lspconfig"},		--????? what for
	{"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function() require('nvim-treesitter.configs').setup {
				ensure_installed = {"go", "lua", "typescript", "javascript", "cpp"},
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
		cmd = {"TSPlaygroundToggle", "TSHighlightCapturesUnderCursor"},
		dependencies = {"nvim-treesitter/nvim-treesitter"},
	},
	{"nvim-tree/nvim-tree.lua",
		config = function() require("nvim-tree").setup({
				git = {
					enable = true,
					ignore = false,
				},
				view = {
					float = {
						enable = true,
						open_win_config = function()
							local screen_w = vim.opt.columns:get()
							local screen_h = vim.opt.lines:get()
							local width = math.floor(screen_w * 0.5)
							local height = math.floor(screen_h * 0.5)
							local row = math.floor((screen_h - height) / 2 - 1)
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
				update_focused_file = {enable = true},
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
					local nvimtree_api = require("nvim-tree.api")
					local function nvimtree_opts(desc)
						return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
					end
					vim.keymap.set('n', "<CR>", "<Nop>", { buffer = bufnr })
					vim.keymap.set('n', 'a', nvimtree_api.fs.create, nvimtree_opts('Create'))
					vim.keymap.set('n', 'r', nvimtree_api.fs.rename, nvimtree_opts('Rename'))
					vim.keymap.set('n', 'c', nvimtree_api.fs.copy.node, nvimtree_opts('Copy'))
					vim.keymap.set('n', "q", nvimtree_api.node.open.edit, nvimtree_opts("Open"))
					vim.keymap.set('n', "R", nvimtree_api.tree.reload, nvimtree_opts("Refresh"))
					vim.keymap.set('n', 'd', function() nvimtree_api.fs.remove(); nvimtree_api.tree.reload() end, nvimtree_opts('Delete'))
					vim.keymap.set('n', 'p', function() nvimtree_api.fs.paste(); nvimtree_api.tree.reload() end, nvimtree_opts('Paste'))
					vim.keymap.set('n', 'Q', function()
						local node = nvimtree_api.tree.get_node_under_cursor()
						if node then
							if node.type == 'directory' then
								nvimtree_api.tree.change_root_to_node(node)
							end
						end
					end, nvimtree_opts('Set root to node under cursor'))
				end,
			})
		end
	},
})



-- =============
-- Keymaps
-- =============
vim.keymap.set('n', '<C-e>', function() vim.diagnostic.open_float() end, {silent = true})
vim.keymap.set('n', '<leader>yy', '"+yy', {noremap = true, silent = true})
vim.keymap.set('v', '<leader>y', '"+y', {noremap = true, silent = true})
vim.keymap.set('n', '<leader>p', '"+p', {noremap = true, silent = true})
vim.keymap.set('n', "<leader><Cr>", function()
	vim.cmd.vnew()
	vim.cmd.term()
	vim.cmd.wincmd("J")
	vim.api.nvim_win_set_height(0, 8)
	vim.api.nvim_win_set_option(0, 'winhighlight', 'Normal:TermBg')
	vim.cmd('highlight TermBg guibg=#141414')
end)
vim.keymap.set('n', '<C-q>', ':NvimTreeToggle<CR>', {noremap = true, silent = true})
local cmp = require("cmp")
local cmp_mappings = {
	["<C-d>"] = cmp.mapping.select_next_item(),
	["<C-a>"] = cmp.mapping.select_prev_item(),
	["<CR>"] = cmp.mapping.confirm({select = true}),
	["<C-Space>"] = cmp.mapping.complete(),
}



-- =============
-- Snippets
-- =============
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



-- =============
-- Completion
-- =============
local cmp = require("cmp")
cmp.setup({
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
	snippet = {
		expand = function(args) luasnip.lsp_expand(args.body) end,
	},
	mapping = cmp.mapping.preset.insert(cmp_mappings),
	sources = {
		{name = "nvim_lsp"},
		{name = "luasnip", keyword_length = 3},
		{name = "buffer", keyword_length = 4},
		{name = "path"},
	},
})



-- =============
-- Lsp
-- =============
local capabilities = require("cmp_nvim_lsp").default_capabilities()
capabilities.textDocument.semanticTokens = nil
vim.lsp.config("clangd", {
	capabilities = capabilities,
	filetypes = {"cpp"},
	cmd = {"clangd"},
})
vim.lsp.config("ts_ls", {
	capabilities = capabilities,
	filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
})



-- =============
-- Golang
-- =============
if vim.fn.executable("gopls") == 0 then
	vim.api.nvim_err_writeln("Gopls not installed! INSTALL IT RIGHT NOW!!!!")
	return
end
local function gopls(bufnr)
	local client_id = vim.lsp.start({
		name = "gopls",
		cmd = {"gopls"},
		capabilities = capabilities,
		root_dir = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)),
		on_attach = function(client, bufnr)
			local opts = {noremap = true, silent = true, buffer = bufnr}
			vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		end,

	})
	vim.lsp.buf_attach_client(bufnr, client_id)
end
vim.api.nvim_create_autocmd("FileType", {
	pattern = "go",
	callback = function(args)
		gopls(args.buf)
	end,
})



-- =============
-- Bash
-- =============
if vim.fn.executable("shellcheck") == 0 then
	vim.api.nvim_err_writeln("Shellcheck not installed! INSTALL IT RIGHT NOW!!!!")
	return
end
local shellcheck_ns = vim.api.nvim_create_namespace("shellcheck")
local severity_map = {
	error =		vim.diagnostic.severity.ERROR,
	warning =	vim.diagnostic.severity.WARN,
	info =		vim.diagnostic.severity.INFO,
	style =		vim.diagnostic.severity.HINT,
}
local function shellcheck(bufnr)
	local fname = vim.api.nvim_buf_get_name(bufnr)
	if fname == "" then return end

	local output = vim.system({
		"shellcheck",
		"--format=json",
		"--exclude=SC2155,SC2034,SC1090,SC2181",
		fname,
	}, {text = true}, function(res)
		if vim.v.shell_error ~= 0 and output == "" then return end

		local ok, decoded = pcall(vim.json.decode, res.stdout)
		if not ok or not decoded then return end

		local diagnostics = {}
		for _, d in ipairs(decoded or {}) do
			table.insert(diagnostics, {
				lnum = d.line - 1,
				col = (d.column or 1) -1 ,
				end_lnum = (d.endLine or d.line) - 1,
				end_col = (d.endColumn or d.column or 1) - 1,
				severity = severity_map[d.level] or vim.diagnostic.severity.ERROR,
				message = ("SC%d: %s"):format(d.code, d.message),
				source = "shellcheck",
			})
		end

		vim.schedule(function()
			vim.diagnostic.set(shellcheck_ns, bufnr, diagnostics, {})
		end)
	end)
end
vim.api.nvim_create_autocmd("FileType", {
	pattern = "sh",
	callback = function(args)
		shellcheck(args.buf)

		vim.api.nvim_create_autocmd("BufWritePost", {
			buffer = args.buf,
			callback = function(args)
				shellcheck(args.buf)
			end,
		})
	end,
})



-- =============
-- TermOpen
-- =============
vim.api.nvim_create_autocmd('TermOpen', {
	group = vim.api.nvim_create_augroup('custom-term-open', {clear = true}),
	callback = function()
		vim.cmd("startinsert")
		vim.opt.number = false
		vim.opt.relativenumber = false
	end,
})



-- =============
-- Theme
-- =============
vim.cmd("syntax off")
vim.cmd("highlight clear")
vim.cmd("colorscheme default")
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
vim.api.nvim_create_user_command("What", "TSHighlightCapturesUnderCursor", {})
for _, group in ipairs(vim.fn.getcompletion("@", "highlight")) do pcall(vim.api.nvim_set_hl, 0, group, {}) end
vim.api.nvim_set_hl(0, "Normal",			{ fg = "#ffffff", bg = "#000000", bold = true })
vim.api.nvim_set_hl(0, "NvimTreeClosedFolderIcon",	{ fg = "#ffffff", bg = "NONE", })
vim.api.nvim_set_hl(0, "NvimTreeClosedFolderName",	{ fg = "#ffffff", bg = "NONE", })
vim.api.nvim_set_hl(0, "NvimTreeOpenedFolderIcon",	{ fg = "#ffffff", bg = "NONE", bold = true })
vim.api.nvim_set_hl(0, "NvimTreeOpenedFolderName",	{ fg = "#ffffff", bg = "NONE", })
vim.api.nvim_set_hl(0, "NvimTreeFolderName",		{ fg = "#ffffff", bg = "NONE", })
vim.api.nvim_set_hl(0, "NvimTreeFileIcon",		{ fg = "#ffffff", bg = "NONE", bold = true})
vim.api.nvim_set_hl(0, "NvimTreeEmptyFolderName",	{ fg = "#ff9999", bg = "NONE", })
vim.api.nvim_set_hl(0, "CmpPmenu",       		{ fg = "#ffffff", bg = "#000000", })
vim.api.nvim_set_hl(0, "CmpPmenuThumb",  		{ bg = "#ffffff" })
vim.api.nvim_set_hl(0, "CmpPmenuSbar",   		{ bg = "#000000" })
vim.api.nvim_set_hl(0, "CmpItemAbbr",    		{ fg = "#ffffff" })
vim.api.nvim_set_hl(0, "CmpItemAbbrMatch",		{ fg = "#ffffff" })
vim.api.nvim_set_hl(0, "CmpItemKind",   		{ fg = "#7f7f7f", italic = true })
vim.api.nvim_set_hl(0, "CmpItemMenu",    		{ fg = "#7f7f7f", italic = true })
vim.api.nvim_set_hl(0, "CmpPmenuSel",    		{ fg = "#000000", bg = "#00ffff", bold = true })
vim.api.nvim_set_hl(0, "Normal",			{ fg = "#ffffff", bg = "NONE"})
vim.api.nvim_set_hl(0, "LineNr",			{ fg = "#999999", bg = "NONE" })
vim.api.nvim_set_hl(0, "StatusLine",			{ fg = "#000000", bg = "#ffffff", bold = true })
vim.api.nvim_set_hl(0, "StatusLineNC",			{ fg = "#ffffff", bg = "#000000" })
vim.api.nvim_set_hl(0, '@keyword',			{ fg = "#ffffff", bold = true })
vim.api.nvim_set_hl(0, '@number',			{ fg = "#ffffff", bold = true })
vim.api.nvim_set_hl(0, '@string',			{ fg = "#ffffff", bold = true })
vim.api.nvim_set_hl(0, '@type',				{ fg = "#26ff00", bold = true })
vim.api.nvim_set_hl(0, '@function.method.call',		{ fg = "#26ff00", bold = false })
vim.api.nvim_set_hl(0, '@function.call',		{ fg = "#26ff00", bold = false })
