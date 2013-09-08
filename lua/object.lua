
object = {}

object.proto = {

	name = "Unnamed object",
	face = "*",
	color = curses.green,

	x = 0,
	y = 0,
	map = nil,

	onUse = function()
		return true
	end,

	onWear = function()
		return true
	end,

	-- class should be one of: none, weapon, armor, consumable, junk
	class = "none",
	specific = {},

	flags = {}
}

