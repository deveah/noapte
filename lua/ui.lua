
ui = {}

function ui.init()
	ui.cols, ui.rows = curses.init()
	log.file:write( "[ui] Screen has " .. ui.cols .. " cols and " .. ui.rows
		.. " rows.\n" )

	ui.camera = {}
	ui.camera.x = 0
	ui.camera.y = 0
end

function ui.terminate()
	curses.terminate()
end

function ui.drawMainScreen()
	ui.updateCamera()

	for i = 0, ui.cols - 1 do
		for j = 0, ui.rows - 1 do
			local ax = i + ui.camera.x - math.floor( ui.cols/2 )
			local ay = j + ui.camera.y - math.floor( ui.rows/2 )

			if map.isLegal( game.player.map, ax, ay ) then
				local e = entity.findByPosition( game.player.map, ax, ay )
				if e and e.active then
					curses.attr( e.color )
					curses.write( i, j, e.face )
				else
					curses.attr( game.player.map.terrain[ax][ay].color )
					curses.write( i, j, game.player.map.terrain[ax][ay].face )
				end
			else
				curses.write( i, j, " " )
			end
		end
	end
end

function ui.isOnScreen( x, y )
	assert( type( x ) == "number" )
	assert( type( y ) == "number" )
	
	return x >= 0 and y >= 0 and x < ui.cols and y < ui.rows
end

function ui.updateCamera()
	while ui.camera.x - game.player.x < -math.floor( ui.cols * 0.25 ) do
		ui.camera.x = ui.camera.x + 1
	end

	while ui.camera.x - game.player.x > math.floor( ui.cols * 0.25 ) do
		ui.camera.x = ui.camera.x - 1
	end

	while ui.camera.y - game.player.y < -math.floor( ui.rows * 0.25 ) do
		ui.camera.y = ui.camera.y + 1
	end

	while ui.camera.y - game.player.y > math.floor( ui.rows * 0.25 ) do
		ui.camera.y = ui.camera.y - 1
	end
end

function ui.centerCameraOnPlayer()
	ui.camera.x = game.player.x
	ui.camera.y = game.player.y
end

