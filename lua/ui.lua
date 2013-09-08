
ui = {}

function ui.init()
	ui.cols, ui.rows = curses.init()
	log.file:write( "[ui] Screen has " .. ui.cols .. " cols and " .. ui.rows
		.. " rows.\n" )
end

function ui.terminate()
	curses.terminate()
end

function ui.drawMainScreen()
	for i = 0, ui.cols do
		for j = 0, ui.rows do
			local ax, ay = i+1, j+1
			if map.isLegal( game.player.map, ax, ay ) then
				curses.attr( game.player.map.terrain[ax][ay].color )
				curses.write( i, j, game.player.map.terrain[ax][ay].face )
			end
		end
	end

	for i = 1, #game.entity do
		local e = game.entity[i]
		local ax, ay = e.x-1, e.y-1

		if	e.map == game.player.map and
			ui.isOnScreen( ax, ay ) and
			e.active then
			curses.attr( e.color )
			curses.write( ax, ay, e.face )
		end
	end
end

function ui.isOnScreen( x, y )
	assert( type( x ) == "number" )
	assert( type( y ) == "number" )
	
	return x >= 0 and y >= 0 and x < ui.cols and y < ui.rows
end

