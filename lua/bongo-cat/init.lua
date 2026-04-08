local M = {}

M.icons = {
	both_idle = "\u{E0FA}",
	both_pressed = "\u{E0FB}",
	right_pressed = "\u{E0FC}",
	left_pressed = "\u{E0FD}",
}

M.config = {
	active_modes = { "i", "t", "R" },
	animation_delay = 150,
}

local state = {
	current = "both_idle",
	last_paw = "right",
}

function M.get_font_path()
	local plugin_path = debug.getinfo(1, "S").source:match("@(.*[/\\])lua[/\\]bongo%-cat[/\\]init.lua$")
	if plugin_path then
		return plugin_path .. "fonts/BongoCat.ttf"
	end
	return nil
end

function M.install_font_instructions()
	local font_path = M.get_font_path()
	if not font_path then
		print("[BongoCat] Не удалось определить путь к шрифту")
		return
	end

	local os_name = vim.loop.os_uname().sysname
	print("\n[BongoCat] Шрифт находится здесь:")
	print("  " .. font_path)
	print("\nУстановите его вручную:")
	if os_name == "Darwin" then
		print("  macOS: дважды кликните по файлу и нажмите 'Установить'")
	elseif os_name == "Linux" then
		print("  Linux: скопируйте в ~/.local/share/fonts/ и выполните fc-cache -fv")
	else
		print("  Windows: кликните правой кнопкой → 'Установить'")
	end
end

function M.get_icon()
	local mode = vim.api.nvim_get_mode().mode
	if not vim.tbl_contains(M.config.active_modes, mode) then
		return M.icons.both_idle
	end
	return M.icons[state.current]
end

local function set_state(new_state)
	state.current = new_state
	vim.cmd("redrawstatus")
end

function M.setup(user_config)
	M.config = vim.tbl_deep_extend("force", M.config, user_config or {})

	vim.api.nvim_create_user_command("BongoCatInstallFont", function()
		M.install_font_instructions()
	end, {})

	vim.api.nvim_create_autocmd("InsertCharPre", {
		callback = function()
			local mode = vim.api.nvim_get_mode().mode
			if not vim.tbl_contains(M.config.active_modes, mode) then
				return
			end

			local char = vim.v.char

			if char == " " then
				set_state("both_pressed")
				vim.defer_fn(function()
					if vim.tbl_contains(M.config.active_modes, vim.api.nvim_get_mode().mode) then
						set_state("both_idle")
					end
				end, M.config.animation_delay)
				return
			end

			if state.last_paw == "left" then
				set_state("right_pressed")
				state.last_paw = "right"
			else
				set_state("left_pressed")
				state.last_paw = "left"
			end

			vim.defer_fn(function()
				if vim.tbl_contains(M.config.active_modes, vim.api.nvim_get_mode().mode) then
					set_state("both_idle")
				end
			end, M.config.animation_delay)
		end,
	})

	vim.api.nvim_create_autocmd("ModeChanged", {
		callback = function()
			local mode = vim.api.nvim_get_mode().mode
			if not vim.tbl_contains(M.config.active_modes, mode) then
				set_state("both_idle")
			end
		end,
	})

	vim.schedule(function()
		local font_path = M.get_font_path()
		if font_path and vim.fn.filereadable(font_path) == 1 then
			vim.notify(
				"[BongoCat] Плагин загружен! Выполните :BongoCatInstallFont для инструкции по установке шрифта",
				vim.log.levels.INFO
			)
		end
	end)
end

return M
