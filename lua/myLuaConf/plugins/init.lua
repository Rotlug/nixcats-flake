local colorschemeName = nixCats("theme_dark")
if not require("nixCatsUtils").isNixCats then
	colorschemeName = "onedark"
end

-- Colorscheme config
if colorschemeName:match("fox$") then
	require("nightfox").setup({
		options = {
			styles = {
				comments = "italic",
				types = "italic,bold",
			},
		},
	})
elseif colorschemeName == "everforest" then
	vim.g.everforest_background = "hard"
end

if not nixCats("dynamic_theme") then
	vim.cmd.colorscheme(colorschemeName)
else
	-- Listen for theme changes
	local function get_hl(name)
		local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
		if not ok then
			return
		end
		return hl
	end

	vim.api.nvim_create_autocmd("OptionSet", {
		pattern = "background",
		callback = function()
			if vim.o.background == "dark" then
				vim.cmd.colorscheme(nixCats("theme_dark"))
				local fg = get_hl("LspInlayHint").fg
				vim.api.nvim_set_hl(0, "LspInlayHint", { bg = "NONE", fg = fg })
			else
				vim.cmd.colorscheme(nixCats("theme_light"))
				local fg = get_hl("LspInlayHint").fg
				vim.api.nvim_set_hl(0, "LspInlayHint", { bg = "NONE", fg = fg })
			end
		end,
	})
end

local ok, notify = pcall(require, "notify")
if ok then
	notify.setup({
		on_open = function(win)
			vim.api.nvim_win_set_config(win, { focusable = false })
		end,
	})
	vim.notify = notify
	vim.keymap.set("n", "<Esc>", function()
		notify.dismiss({ silent = true })
	end, { desc = "dismiss notify popup and clear hlsearch" })
end

if nixCats("transparnet") then
	require("transparent").setup({})
end

require("lze").load({
	{ import = "myLuaConf.plugins.treesitter" },
	{ import = "myLuaConf.plugins.completion" },
	{
		"markdown-preview.nvim",
		-- NOTE: for_cat is a custom handler that just sets enabled value for us,
		-- based on result of nixCats('cat.name') and allows us to set a different default if we wish
		-- it is defined in luaUtils template in lua/nixCatsUtils/lzUtils.lua
		-- you could replace this with enabled = nixCats('cat.name') == true
		-- if you didnt care to set a different default for when not using nix than the default you already set
		for_cat = "general.markdown",
		cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
		ft = "markdown",
		keys = {
			{ "<leader>mp", "<cmd>MarkdownPreview <CR>", mode = { "n" }, noremap = true, desc = "markdown preview" },
			{
				"<leader>ms",
				"<cmd>MarkdownPreviewStop <CR>",
				mode = { "n" },
				noremap = true,
				desc = "markdown preview stop",
			},
			{
				"<leader>mt",
				"<cmd>MarkdownPreviewToggle <CR>",
				mode = { "n" },
				noremap = true,
				desc = "markdown preview toggle",
			},
		},
		before = function(plugin)
			vim.g.mkdp_auto_close = 0
		end,
	},
	{
		"undotree",
		for_cat = "general.extra",
		cmd = { "UndotreeToggle", "UndotreeHide", "UndotreeShow", "UndotreeFocus", "UndotreePersistUndo" },
		keys = { { "<leader>U", "<cmd>UndotreeToggle<CR>", mode = { "n" }, desc = "Undo Tree" } },
		before = function(_)
			vim.g.undotree_WindowLayout = 1
			vim.g.undotree_SplitWidth = 40
		end,
	},
	{
		"todo-comments.nvim",
		for_cat = "general.extra",
		event = "DeferredUIEnter",
		after = function(plugin)
			require("todo-comments").setup()
		end,
	},
	{
		"nvim-ufo",
		for_cat = "general.always",
		event = "DeferredUIEnter",
		after = function(plugin)
			require("ufo").setup({})

			vim.o.foldcolumn = "0" -- '0' is not bad
			vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
			vim.o.foldlevelstart = 99
			vim.o.foldenable = true

			-- Toggle fold under cursor with Shift+Enter
			vim.keymap.set("n", "<S-CR>", "za", { desc = "Toggle fold under cursor (Shift+Enter)" })
		end,
	},
	{
		"comment.nvim",
		for_cat = "general.extra",
		event = "DeferredUIEnter",
		after = function(plugin)
			require("Comment").setup()
			-- Alt+/ to toggle comment
			-- For normal mode
			vim.keymap.set("n", "<A-/>", function()
				require("Comment.api").toggle.linewise.current()
			end, { desc = "Toggle comment", silent = true })
			-- For visual mode (comment selection)
			vim.keymap.set("x", "<A-/>", function()
				local esc = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
				vim.api.nvim_feedkeys(esc, "nx", false)
				require("Comment.api").toggle.linewise(vim.fn.visualmode())
			end, { desc = "Toggle comment (visual)", silent = true })
		end,
	},
	{
		"nvim-surround",
		for_cat = "general.always",
		event = "DeferredUIEnter",
		-- keys = "",
		after = function(plugin)
			require("nvim-surround").setup()
		end,
	},
	{
		"mini.pairs",
		for_cat = "general.always",
		event = "DeferredUIEnter",
		after = function(plugin)
			require("mini.pairs").setup({
				mappings = {
					["'"] = false,
				},
			})
		end,
	},
	{
		"vim-startuptime",
		for_cat = "general.extra",
		cmd = { "StartupTime" },
		before = function(_)
			vim.g.startuptime_event_width = 0
			vim.g.startuptime_tries = 10
			vim.g.startuptime_exe_path = nixCats.packageBinPath
		end,
	},
	{
		"fidget.nvim",
		for_cat = "general.extra",
		event = "DeferredUIEnter",
		-- keys = "",
		after = function(plugin)
			require("fidget").setup({})
		end,
	},
	-- {
	--   "hlargs",
	--   for_cat = 'general.extra',
	--   event = "DeferredUIEnter",
	--   -- keys = "",
	--   dep_of = { "nvim-lspconfig" },
	--   after = function(plugin)
	--     require('hlargs').setup {
	--       color = '#32a88f',
	--     }
	--     vim.cmd([[hi clear @lsp.type.parameter]])
	--     vim.cmd([[hi link @lsp.type.parameter Hlargs]])
	--   end,
	-- },
	{
		"lualine.nvim",
		for_cat = "general.always",
		-- cmd = { "" },
		event = "DeferredUIEnter",
		-- ft = "",
		-- keys = "",
		-- colorscheme = "",
		after = function(plugin)
			require("lualine").setup({
				options = {
					icons_enabled = false,
					-- theme = colorschemeName,
					component_separators = " ",
					section_separators = "",
				},
				sections = {
					lualine_c = {
						{
							"filename",
							path = 1,
							status = true,
						},
					},
				},
				inactive_sections = {
					lualine_b = {
						{
							"filename",
							path = 3,
							status = true,
						},
					},
					lualine_x = { "filetype" },
				},
			})
		end,
	},
	{
		"nvim-ts-autotag",
		for_cat = "webdev",
		event = "DeferredUIEnter",
		after = function(plugin)
			require("nvim-ts-autotag").setup()
		end,
	},
	{
		"gitsigns.nvim",
		for_cat = "general.always",
		event = "DeferredUIEnter",
		-- cmd = { "" },
		-- ft = "",
		-- keys = "",
		-- colorscheme = "",
		after = function(plugin)
			require("gitsigns").setup({
				-- See `:help gitsigns.txt`
				signs = {
					add = { text = "+" },
					change = { text = "~" },
					delete = { text = "_" },
					topdelete = { text = "‾" },
					changedelete = { text = "~" },
				},
				on_attach = function(bufnr)
					local gs = package.loaded.gitsigns

					local function map(mode, l, r, opts)
						opts = opts or {}
						opts.buffer = bufnr
						vim.keymap.set(mode, l, r, opts)
					end

					-- Navigation
					map({ "n", "v" }, "]c", function()
						if vim.wo.diff then
							return "]c"
						end
						vim.schedule(function()
							gs.next_hunk()
						end)
						return "<Ignore>"
					end, { expr = true, desc = "Jump to next hunk" })

					map({ "n", "v" }, "[c", function()
						if vim.wo.diff then
							return "[c"
						end
						vim.schedule(function()
							gs.prev_hunk()
						end)
						return "<Ignore>"
					end, { expr = true, desc = "Jump to previous hunk" })

					-- Actions
					-- visual mode
					map("v", "<leader>hs", function()
						gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end, { desc = "stage git hunk" })
					map("v", "<leader>hr", function()
						gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end, { desc = "reset git hunk" })
					-- normal mode
					map("n", "<leader>gs", gs.stage_hunk, { desc = "git stage hunk" })
					map("n", "<leader>gr", gs.reset_hunk, { desc = "git reset hunk" })
					map("n", "<leader>gS", gs.stage_buffer, { desc = "git Stage buffer" })
					map("n", "<leader>gu", gs.undo_stage_hunk, { desc = "undo stage hunk" })
					map("n", "<leader>gR", gs.reset_buffer, { desc = "git Reset buffer" })
					map("n", "<leader>gp", gs.preview_hunk, { desc = "preview git hunk" })
					map("n", "<leader>gb", function()
						gs.blame_line({ full = false })
					end, { desc = "git blame line" })
					map("n", "<leader>gd", gs.diffthis, { desc = "git diff against index" })
					map("n", "<leader>gD", function()
						gs.diffthis("~")
					end, { desc = "git diff against last commit" })

					-- Toggles
					map("n", "<leader>gtb", gs.toggle_current_line_blame, { desc = "toggle git blame line" })
					map("n", "<leader>gtd", gs.toggle_deleted, { desc = "toggle git show deleted" })

					-- Text object
					map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "select git hunk" })
				end,
			})
			vim.cmd([[hi GitSignsAdd guifg=#04de21]])
			vim.cmd([[hi GitSignsChange guifg=#83fce6]])
			vim.cmd([[hi GitSignsDelete guifg=#fa2525]])
		end,
	},
	{
		"which-key.nvim",
		for_cat = "general.extra",
		-- cmd = { "" },
		event = "DeferredUIEnter",
		-- ft = "",
		-- keys = "",
		-- colorscheme = "",
		after = function(plugin)
			require("which-key").setup({})
			require("which-key").add({
				{ "<leader>b", group = "buffer commands" },
				{ "<leader><leader>_", hidden = true },
				{ "<leader>c", group = "[c]ode" },
				{ "<leader>c_", hidden = true },
				{ "<leader>d", group = "[d]ocument" },
				{ "<leader>d_", hidden = true },
				{ "<leader>g", group = "[g]it" },
				{ "<leader>g_", hidden = true },
				{ "<leader>m", group = "[m]arkdown" },
				{ "<leader>m_", hidden = true },
				{ "<leader>r", group = "[r]ename" },
				{ "<leader>r_", hidden = true },
				{ "<leader>s", group = "[s]earch" },
				{ "<leader>s_", hidden = true },
				{ "<leader>t", group = "[t]oggles" },
				{ "<leader>t_", hidden = true },
				{ "<leader>w", group = "[w]orkspace" },
				{ "<leader>w_", hidden = true },
			})
		end,
	},
	{
		"snacks.nvim",
		for_cat = "general.extra",
		after = function(plugin)
			require("snacks").setup({
				picker = {
					enabled = true,
				},

				explorer = {
					enabled = true,
					replace_netrw = true,
					trash = true,
				},

				notifier = {
					enable = true,
				},
			})

			--- Keymaps
			-- File picker
			vim.keymap.set("n", "<leader>-", function()
				Snacks.picker.files()
			end, { desc = "Find files (filename match)" })
			vim.keymap.set("n", "<leader>/", function()
				Snacks.picker.grep()
			end, { desc = "Search contents" })

			-- Explorer
			vim.keymap.set("n", "<leader>e", function()
				Snacks.explorer()
			end, { desc = "Toggle File picker" })
		end,
	},
})
