local t = vim.loop.hrtime()
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		local delta = (vim.loop.hrtime() - t) / 1e6
		print("VimEnter after " .. delta .. "ms")
	end,
})
local function split_string(input)
	local lines = {}
	if input == nil then return lines end
	for line in input:gmatch("([^\n]+)") do
		table.insert(lines, line)
	end
	return lines
end
local popups = {}
local function popup(lines)
	if type(lines) == "string" then lines = split_string(lines) end
	if next(lines) == nil then return end
	if #lines == 1 and lines[1] == "" then return end
	if lines[#lines] == "" then table.remove(lines) end

	local wid = 50
	for _, line in ipairs(lines) do
		local len = vim.fn.strdisplaywidth(line)
		if len > wid then wid = len end
	end

	local row = 5
	if next(popups) ~= nil then
		row = popups[#popups].row + popups[#popups].hei + 1
	end

	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	local win = vim.api.nvim_open_win(buf, false, {
		relative = "editor",
		width = wid,
		height = #lines,
		row = row,
		col = 10,
		style = "minimal",
		border = "single",
	})
	table.insert(popups, {buf = buf, win = win, row = row, hei = #lines + 2})
end



--[[
--	Opts
--]]
vim.g.mapleader = " "
vim.opt.wrap = false
vim.opt.number = true
vim.opt.swapfile = false
vim.opt.termguicolors = true
vim.opt.relativenumber = true
vim.keymap.set("n", "<C-e>", function() vim.diagnostic.open_float(nil, {border = "rounded"}) end, {noremap = true, silent = true})
vim.keymap.set("n", "<leader>yy", "\"+yy", {noremap = true, silent = true})
vim.keymap.set("v", "<leader>y", "\"+y", {noremap = true, silent = true})
vim.keymap.set("n", "<leader>p", "\"+p", {noremap = true, silent = true})
vim.keymap.set("n", "<leader><Cr>", function()
	vim.cmd.vnew()
	vim.cmd.term()
	vim.cmd.wincmd("J")
	vim.api.nvim_win_set_height(0, 12)
	vim.cmd("startinsert")
	vim.defer_fn(function()
		vim.api.nvim_chan_send(vim.b.terminal_job_id, "ls\n")
	end, 32)
end)



--[[
--	Bootstrap
--]]
local mini_ok = true
local mini_repo = "https://github.com/nvim-mini/mini.nvim"
local mini_path = vim.fn.stdpath("data") .. "/site/pack/deps/start/mini.nvim"
if not vim.loop.fs_stat(mini_path) then
	mini_ok = false
	popup({
		"Installing mini.nvim...",
		"",
		"git clone --depth 1 \\",
		mini_repo .. " \\",
		mini_path,
	})
	vim.fn.jobstart(
		{"git", "clone", "--depth", "1", mini_repo, mini_path},
		{
			stdout_buffered = true,
			stderr_buffered = true,
			on_stdout = function(_, data)
				popup(data)
			end,
			on_stderr = function(_, data)
				popup(data)
			end,
			on_exit = function(_, code)
				if code == 0 then
					popup({
						"Success installing mini.nvim",
						"",
						"Restart nvim to take effect",
					})
				else
					popup("Failed installing mini.nvim")
				end
			end,
		}
	)
end
if mini_ok ~= true then return end



--[[
--	Plugins
--]]
local deps = require("mini.deps")
deps.setup()
deps.add({
	source = "nvim-treesitter/nvim-treesitter",
	checkout = "master",
	hooks = {post_checkout = function() vim.cmd("TSUpdate") end},
})
deps.add({
	source = "hrsh7th/nvim-cmp",
})
deps.add({
	source = "hrsh7th/cmp-path",
})
deps.add({
	source = "hrsh7th/cmp-buffer",
})
deps.add({
	source = "hrsh7th/cmp-nvim-lsp",
})
deps.add({
	source = "saadparwaiz1/cmp_luasnip",
})
deps.add({
	source = "L3MON4D3/LuaSnip",
})
deps.add({
	source = "rafamadriz/friendly-snippets",
})
deps.add({
	source = "neovim/nvim-lspconfig",
})
deps.add({
	source = "nvim-tree/nvim-tree.lua",
})
deps.add({
	source = "lewis6991/gitsigns.nvim",
})



--[[
--	Treesitter
--]]
require("nvim-treesitter.configs").setup({
	ensure_installed = {
		"go",
		"lua",
	},
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
	semantic_tokens = {
		enable = true,
	},
})



--[[
--	Nvimtree
--]]
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.keymap.set("n", "<C-q>", ":NvimTreeToggle<CR>", {noremap = true, silent = true})
require("nvim-tree").setup({
	hijack_directories = {
		enable = false,
	},
	filters = {
		dotfiles = false,
	},
	update_focused_file = {
		enable = true,
	},
	filesystem_watchers = {
		enable = true,
		debounce_delay = 50,
	},
	git = {
		enable = true,
		ignore = false,
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
					empty_open = "v",
					symlink = "->",
					symlink_open = "->",
				},
			},
		},
	},
	view = {
		float = {
			enable = true,
			open_win_config = function()
				local buf_w = vim.opt.columns:get()
				local buf_h = vim.opt.lines:get()
				local wid = math.floor(buf_w * 0.5)
				local hei = math.floor(buf_h * 0.5)
				local row = math.floor((buf_h - hei) / 2 - 1)
				local col = math.floor((buf_w - wid) / 2)
				return {
					relative = "editor",
					border = "rounded",
					width = wid,
					height = hei,
					row = row,
					col = col,
				}
			end,
		},
	},
	on_attach = function(bufnr)
		local nvimtree_api = require("nvim-tree.api")
		local function nvimtree_opts(desc)
			return {desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true}
		end
		vim.keymap.set("n", "<CR>", "<Nop>", nvimtree_opts("Enter"))
		vim.keymap.set("n", "a", nvimtree_api.fs.create, nvimtree_opts("Create"))
		vim.keymap.set("n", "r", nvimtree_api.fs.rename, nvimtree_opts("Rename"))
		vim.keymap.set("n", "c", nvimtree_api.fs.copy.node, nvimtree_opts("Copy"))
		vim.keymap.set("n", "q", nvimtree_api.node.open.edit, nvimtree_opts("Open"))
		vim.keymap.set("n", "R", nvimtree_api.tree.reload, nvimtree_opts("Refresh"))
		vim.keymap.set("n", "d", function() nvimtree_api.fs.remove(); nvimtree_api.tree.reload() end, nvimtree_opts("Delete"))
		vim.keymap.set("n", "p", function() nvimtree_api.fs.paste(); nvimtree_api.tree.reload() end, nvimtree_opts("Paste"))
		vim.keymap.set("n", "Q", function()
			local node = nvimtree_api.tree.get_node_under_cursor()
			if node and node.type == "directory" then nvimtree_api.tree.change_root_to_node(node) end
		end, nvimtree_opts("Set root"))
	end,
})
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		local args = vim.fn.argv()
		if #args == 1 and vim.fn.isdirectory(args[1]) == 1 then
			vim.cmd("enew")
			require("nvim-tree.api").tree.open({
				path = args[1],
				focus = true,
				find_file = false,
			})
		end
	end,
})



--[[
--	Gitsigns
--]]
require("gitsigns").setup({
	attach_to_untracked = false,
	current_line_blame = true,
	current_line_blame_opts = {
		virt_text = true,
		delay = 500,
	},
	preview_config = {
		border = "single",
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
			for _, w in ipairs(wins) do if w ~= win then vim.api.nvim_set_current_win(w); break end end
		end, {buffer = bufnr})
	end,
})



--[[
--	Snippets
--]]
local luasnip = require("luasnip")
do
	local s = luasnip.snippet
	local t = luasnip.text_node
	luasnip.add_snippets("go", {
		s("ien", {
			t("if err != nil {"),
			t({"", "\treturn err"}),
			t({"", "}"}),
		}),
	})
end



--[[
--	Completions
--]]
local cmp = require("cmp")
cmp.setup({
	sources = {
		{
			name = "path",
		},
		{
			name = "buffer",
			keyword_length = 4,
		},
		{
			name = "nvim_lsp",
		},
		{
			name = "luasnip",
			keyword_length = 3,
		},
	},
	window = {
		completion = cmp.config.window.bordered({border = "rounded", scrollbar = false}),
		documentation = cmp.config.window.bordered({border = "rounded", scrollbar = false}),
	},
	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
	},
	mapping = {
		["<C-s>"] = cmp.mapping.complete(),
		["<C-d>"] = cmp.mapping.select_next_item(),
		["<C-a>"] = cmp.mapping.select_prev_item(),
		["<C-Space>"] = cmp.mapping.confirm({select = true}),
	},
})



--[[
--	Lsp
--]]
local capabilities = require("cmp_nvim_lsp").default_capabilities()
capabilities.textDocument.semanticTokens = nil



--[[
--	Clang
--]]
local function clangd(bufnr)
	local client_id = vim.lsp.start({
		name = "clangd",
		cmd = {"clangd"},
		capabilities = capabilities,
		root_dir = vim.fs.root(0, {".git", ".clangd"}),
		on_attach = function(client, bufnr)
			vim.keymap.set("n", "K", vim.lsp.buf.hover, {noremap = true, silent = true, buffer = bufnr})
		end,
	})
	vim.lsp.buf_attach_client(bufnr, client_id)
end
vim.api.nvim_create_autocmd("FileType", {
	pattern = {"c", "cpp"},
	callback = function(args)
		if vim.fn.executable("clangd") == 0 then popup("Clangd is not installed!"); return end
		clangd(args.buf)
	end,
})



--[[
--	Bash
--]]
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
		"--exclude=SC2034,SC1090,SC2181,SC2261,SC2148",
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
		if vim.fn.executable("shellcheck") == 0 then popup("Shellcheck is not installed!"); return end
		shellcheck(args.buf)
		vim.api.nvim_create_autocmd("BufWritePost", {
			buffer = args.buf,
			callback = function(args)
				shellcheck(args.buf)
			end,
		})
	end,
})



--[[
--	Golang
--]]
local function gopls(bufnr)
	local client_id = vim.lsp.start({
		name = "gopls",
		cmd = {"gopls"},
		capabilities = capabilities,
		root_dir = vim.fs.root(0, {".git", "go.mod"}),
		on_attach = function(client, bufnr)
			vim.keymap.set("n", "K", vim.lsp.buf.hover, {noremap = true, silent = true, buffer = bufnr})
		end,
	})
	vim.lsp.buf_attach_client(bufnr, client_id)
end
vim.api.nvim_create_autocmd("FileType", {
	pattern = "go",
	callback = function(args)
		if vim.fn.executable("gopls") == 0 then popup("Gopls is not installed!"); return end
		gopls(args.buf)
	end,
})



--[[
--	Theme
--]]
vim.api.nvim_set_hl(0, "Normal",			{bg = "#000000",fg = "#ffffff"})
vim.api.nvim_set_hl(0, "NormalFloat",			{bg = "#000000"})
vim.api.nvim_set_hl(0, "FloatBorder",			{bg = "#000000"})
vim.api.nvim_set_hl(0, "LineNr",			{		fg = "#505050"})
vim.api.nvim_set_hl(0, "StatusLine",			{bg = "#757575",fg = "#ffffff",	bold = true})
vim.api.nvim_set_hl(0, "StatusLineNC",			{bg = "#353535",fg = "#bfbfbf"})
vim.api.nvim_set_hl(0, "NvimTreeRootFolder",		{		fg = "#49f3fc", bold = true})
vim.api.nvim_set_hl(0, "NvimTreeEndOfBuffer",		{		fg = "#505050"})
vim.api.nvim_set_hl(0, "NvimTreeFileIcon",		{		fg = "#ffffff",	bold = true})
vim.api.nvim_set_hl(0, "NvimTreeFolderName",		{		fg = "#ffffff"})
vim.api.nvim_set_hl(0, "NvimTreeEmptyFolderName",	{		fg = "#ff9999"})
vim.api.nvim_set_hl(0, "NvimTreeOpenedFolderName",	{		fg = "#ffffff"})
vim.api.nvim_set_hl(0, "NvimTreeOpenedFolderIcon",	{		fg = "#ffffff",	bold = true})
vim.api.nvim_set_hl(0, "NvimTreeClosedFolderName",	{		fg = "#ffffff"})
vim.api.nvim_set_hl(0, "NvimTreeClosedFolderIcon",	{		fg = "#ffffff"})
vim.api.nvim_set_hl(0, "CmpItemAbbr",   		{		fg = "#f0f0f0"})
vim.api.nvim_set_hl(0, "CmpItemKind",   		{		fg = "#a0a0a0",	italic = true})
vim.api.nvim_set_hl(0, "PmenuSel",			{		fg = "#ff0000", bold = true})
