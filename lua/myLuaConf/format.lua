require("lze").load({
	{
		"conform.nvim",
		for_cat = "format",
		cmd = { "ConformInfo" },
		event = { "BufReadPre", "BufNewFile" },
		keys = {
			{ "<leader>FF", desc = "[F]ormat [F]ile" },
		},
		-- colorscheme = "",
		after = function(plugin)
			local conform = require("conform")

			conform.setup({
				default_format_opts = {
					lsp_format = "never",
				},
				format_on_save = {
					-- These options will be passed to conform.format()
					timeout_ms = 500,
					lsp_format = "fallback",
				},
				formatters = {
					gdscript_formatter = {
						command = "gdscript-formatter",
						args = { "$FILENAME" },
						stdin = false,
					},
				},
				formatters_by_ft = {
					lua = { "stylua" },
					nix = { "alejandra" },
					python = { "ruff_format", "ruff_fix" },
					gdscript = { "gdscript_formatter" },
					rust = { "rustfmt" },
					javascript = { "prettierd" },
					typescript = { "prettierd" },
					javascriptreact = { "prettierd" },
					typescriptreact = { "prettierd" },
					go = { "goimports-reviser", "gofmt", "golines" },
					qml = { "qmlformat" },
					toml = { "taplo" },
					--- Clang
					c = { "clang-format" },
					cpp = { "clang-format" },
					objc = { "clang-format" },
					objcpp = { "clang-format" },
				},
			})

			vim.keymap.set({ "n", "v" }, "<leader>FF", function()
				conform.format({
					lsp_fallback = true,
					async = false,
					timeout_ms = 1000,
				})
			end, { desc = "[F]ormat [F]ile" })
		end,
	},
})
