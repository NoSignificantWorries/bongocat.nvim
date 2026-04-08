local M = {}

function M.check()
	vim.health.start("BongoCat")

	local ok, bongo = pcall(require, "bongo-cat")
	if not ok then
		vim.health.error("Плагин не загружен")
		return
	end

	local font_path = bongo.get_font_path()
	if font_path and vim.fn.filereadable(font_path) == 1 then
		vim.health.ok("Шрифт найден: " .. font_path)
	else
		vim.health.warn(
			"Шрифт не найден. Выполните :BongoCatInstallFont для инструкции"
		)
	end

	vim.health.info("Активные режимы: " .. table.concat(bongo.config.active_modes, ", "))
	vim.health.info("Задержка анимации: " .. bongo.config.animation_delay .. " мс")
end

return M
