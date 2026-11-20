-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :( 

---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "islands-dark",

	hl_add = {
		DapCurrentMarker = { fg = "#f07178", bold = true },
		DapCurrentLine = { bg = "#303c2c" },
		-- Debugger accents; keep the requested red marker and green stopped line.
		DapUIVariable = { fg = "#c77dbb" },
		DapUIValue = { fg = "#bcbec4" },
		DapUIType = { fg = "#56a8f5" },
		DapUIModifiedValue = { fg = "#ffcb6b", bold = true },
		DapValueString = { fg = "#6aab73" },
		DapValueNumber = { fg = "#2aacb8" },
		DapValueBoolean = { fg = "#cf8e6d" },
		DapValueNil = { fg = "#cf8e6d" },
	},

	-- hl_override = {
	-- 	Comment = { italic = true },
	-- 	["@comment"] = { italic = true },
	-- },
}

-- M.nvdash = { load_on_startup = true }
-- M.ui = {
--       tabufline = {
--          lazyload = false
--      }
-- }

return M
