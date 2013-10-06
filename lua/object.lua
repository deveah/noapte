
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

function object.findByPosition( map, x, y )
	assert( type( map ) == "table" )
	assert( type( x ) == "number" )
	assert( type( y ) == "number" )

	-- multiple objects can exist on the same tile, so a table is returned
	-- if there are no objects found on a certain tile, nil is returned
	local t = {}

	for i = 1, #game.object do
		if game.object[i].map == map and game.object[i].x == x and game.object[i].y == y then
			table.insert( t, game.object[i] )
			log.file:write( "[object.findByPosition] found object " ..
				tostring( game.object[i] ) .. ".\n" )
		end
	end

	if #t == 0 then
		return nil
	else
		return t
	end
end
