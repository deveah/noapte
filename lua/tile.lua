
tile = {}

tile.proto = {
	face = ".",
	color = curses.white,

	moveCost = 0,
	lightCost = 0,

	flags = {}
}

tile.void = {
	face = " ",
	color = curses.black,

	moveCost = 0,
	lightCost = 0,

	flags = { "solid", "opaque" }
}

tile.floor = {
	face = ".",
	color = curses.white,

	moveCost = 1,
	lightCost = 1,

	flags = {}
}

tile.wall = {
	face = "#",
	color = curses.blue + curses.bold,

	moveCost = 0,
	lightCost = 0,

	flags = { "solid", "opaque" }
}

